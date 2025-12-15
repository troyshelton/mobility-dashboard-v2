// XMLCclRequestSimulator - Simple Mock CCL responses for template demo
(function(window) {
    // 'use strict'; // Temporarily disabled for Firebug Lite compatibility
    
    /**
     * XMLCclRequestSimulator - Simulates CCL program responses
     */
    function XMLCclRequestSimulator() {
        this.debugMode = true;
    }
    
    /**
     * Simulate a CCL request
     * @param {string} programName - CCL program name
     * @param {Array} parameters - Program parameters
     * @returns {Promise} - Promise resolving to mock response
     */
    XMLCclRequestSimulator.prototype.simulateRequest = function(programName, parameters) {
        return new Promise((resolve, reject) => {
            if (this.debugMode) {
                console.log(`[XMLCclRequestSimulator] Simulating ${programName} with parameters:`, parameters);
            }
            
            // Simulate network delay
            setTimeout(() => {
                try {
                    const response = this.generateMockResponse(programName, parameters);
                    if (this.debugMode) {
                        console.log(`[XMLCclRequestSimulator] Mock response for ${programName}:`, response);
                    }
                    resolve(response);
                } catch (error) {
                    if (this.debugMode) {
                        console.error(`[XMLCclRequestSimulator] Error generating mock response:`, error);
                    }
                    reject(error);
                }
            }, 100); // 100ms delay (production CCL will have natural 1-3sec delays)
        });
    };
    
    /**
     * Generate mock responses based on program name
     */
    XMLCclRequestSimulator.prototype.generateMockResponse = function(programName, parameters) {
        switch (programName.toLowerCase()) {
            case '1_cust_mp_gen_get_plists':
                return this.getMockPatientLists(parameters);

            case '1_cust_mp_gen_get_pids':
                return this.getMockPatientIds(parameters);

            case '1_cust_mp_gen_get_pdata':
                return this.getMockPatientData(parameters);

            case '1_cust_mp_gen_user_info':
                return this.getMockUserInfo(parameters);

            default:
                throw new Error(`Unknown CCL program: ${programName}`);
        }
    };
    
    /**
     * Mock patient lists - Simple for demo (2 lists)
     */
    XMLCclRequestSimulator.prototype.getMockPatientLists = function(parameters) {
        return {
            rpatlists: {
                applicationId: 0.000000,
                prsnlId: parseInt(parameters[1]) || 8333417,
                qual: [
                    {"viewSeq": 1, "patientListId": 1001.000000, "name": "Demo Patient List A"},
                    {"viewSeq": 2, "patientListId": 1002.000000, "name": "Demo Patient List B"}
                ]
            }
        };
    };
    
    /**
     * Mock patient IDs (Step 1: get encounter IDs from patient list)
     */
    XMLCclRequestSimulator.prototype.getMockPatientIds = function(parameters) {
        const listId = parseInt(parameters[1]) || 1001;

        // Create different patient sets for List A and List B
        let mockPatients;

        if (listId === 1002) {
            // Demo Patient List B - Different patients with different timer states
            mockPatients = [
                { "personId": 22345001, "personName": "Smith, John B", "encntrId": 22345001, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 22345002, "personName": "Johnson, Mary B", "encntrId": 22345002, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 22345003, "personName": "Williams, Robert B", "encntrId": 22345003, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 22345004, "personName": "Brown, Patricia B", "encntrId": 22345004, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 22345005, "personName": "Davis, Michael B", "encntrId": 22345005, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 22345006, "personName": "Miller, Linda B", "encntrId": 22345006, "priority": 0, "activeInd": 1, "filterInd": 0 }
            ];
        } else {
            // Demo Patient List A - Original patients with countdown timer examples
            mockPatients = [
                { "personId": 12345001, "personName": "Patient: 2h 50m left", "encntrId": 12345001, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 12345002, "personName": "Patient: 2h 15m left", "encntrId": 12345002, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 12345003, "personName": "Patient: 1h 45m left", "encntrId": 12345003, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 12345004, "personName": "Patient: 1h 10m left", "encntrId": 12345004, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 12345005, "personName": "Patient: 45m left", "encntrId": 12345005, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 12345006, "personName": "Patient: 15m left", "encntrId": 12345006, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 12345007, "personName": "Patient: 5m left", "encntrId": 12345007, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 12345008, "personName": "Patient: OVERDUE 30m", "encntrId": 12345008, "priority": 0, "activeInd": 1, "filterInd": 0 },
                { "personId": 12345009, "personName": "NO SEPSIS - Control Test", "encntrId": 12345009, "priority": 0, "activeInd": 1, "filterInd": 0 }
            ];
        }

        return {
            ptlstencntrReply: {
                patientcnt: mockPatients.length,
                patientListId: listId,
                name: `Sepsis Countdown Timer Demo`,
                description: "Mock patient list showing various countdown timer states",
                patients: mockPatients,
                statusData: {
                    status: "S",
                    message: `Successfully retrieved ${mockPatients.length} patients`
                }
            }
        };
    };
    
    /**
     * Mock patient data (Step 2: get demographics using encounter IDs)
     * Enhancement 2: Timer countdown demo with 8 patients at various stages
     * Current time: 09/29/25 14:25
     * 3-hour deadline: 180 minutes from Time Zero
     */
    XMLCclRequestSimulator.prototype.getMockPatientData = function(parameters) {
        // Simple patient data for demo - mapped by encounter ID
        const patientDataMap = {
            // Patient 1: HAS alert, HAS screening (show assessment text)
            12345001: {
                PERSON_ID: 12345001,
                ENCNTR_ID: 12345001,
                PATIENT_NAME: "COUNTDOWN, Test A",
                UNIT: "ICU",
                ROOM_BED: "201-A",
                PATIENT_CLASS: "Inpatient",
                STATUS: "Critical",
                ACUITY: "Level 1",
                AGE: 65,
                GENDER: "Male",
                ADMISSION_DATE: "2025-09-01",
                ALERT_TYPE: "Severe Sepsis", // HAS alert
                SEPSIS_SCREEN_ASSESSMENT: "Septic Shock/Severe Sepsis with hypotension has been confirm", // RED icon - confirmed (Issue #41)
                SEPSIS_PRIORITY: "", // Empty for now - future priority implementation
                LAST_SEPSIS_SCREEN: "", // Empty for now - future time zero implementation
                SEPSIS_TIMER: "", // Empty for now - future timer implementation
                POWERPLAN_ORDERED: "Y", // Initiated sepsis PowerPlan
                LACTATE_ORDERED: "Y", // Lactate dispatched
                LACTATE_RESULT: 2.3, // Normal lactate - Perfusion/Pressors should be "N/A"
                BLOOD_CULTURES_ORDERED: "Pend", // Blood cultures dispatched but not collected yet
                screen: [{ // PowerForm assessment data with alert criteria
                    screenId: "PF_SEPSIS_001",
                    resultVal: "Severe Sepsis has been confirmed",
                    completedDateTime: "09/15/25 14:15",
                    completedBy: "Dr. Johnson, MD",
                    alertCriteria: [
                        "Temperature > 38°C (101.2°F)",
                        "Heart Rate > 90 bpm",
                        "WBC > 12,000 cells/mcL",
                        "Lactate > 2.0 mmol/L"
                    ],
                    alertComment: "Patient meets SIRS criteria with suspected infection. Lactate elevated at 2.3. Blood cultures ordered prior to antibiotics."
                }],
                perfusion: [{ // v20: QM Septic Shock Assessment PowerForm (Issue #47)
                    clinicalEventId: 7447618022,
                    eventId: 7447618023,
                    eventCd: 5237301661,
                    eventCdDisp: "QM Septic Shock Assessment - Form",
                    eventTag: "QM Septic Shock Assessment - Form",
                    resultVal: "",
                    eventEndDtTm: "/Date(2025-10-24T20:58:00.000+00:00)/",
                    eventEndDtTmDisp: "10/24/25 16:58",
                    performedPrsnlId: 24794735,
                    performedPrsnlName: "Shelton, Troy P",
                    performedPrsnlPosition: "DBA Lite"
                }],
                timeZero: [{ // Time Zero: 10 minutes ago = 14:15 (2h 50m remaining)
                    type: "Diagnosis",
                    diagDtTmDisp: "09/29/25 14:15",
                    diagId: 11808191001,
                    diagDisplay: "Severe sepsis"
                }],
                ANTIBIOTICS_ORDERED: "Y", // Sepsis antibiotics ordered (piperacillin/tazobactam in sepsis phase)
                REPEAT_LACTATE_ORDERED: "", // Empty for now - future CCL implementation
                SEPSIS_FLUID_ORDERED: "Y", // Sepsis fluids ordered (sodium chloride in sepsis phase)
                FLUID_VOLUME_DOCUMENTED: "", // Empty for now - future CCL implementation
                PERFUSION_ASSESSMENT: "", // Empty for now - future CCL implementation
                PRESSORS_ORDERED: "", // Empty for now - future CCL implementation
                powerplans: [{
                    ppPowerplanName: "ED Severe Sepsis - ADULT",
                    ppPatientName: "ZZZTEST, John Doe",
                    ppFinNumber: "3010319001",
                    phase: [{
                        pStatus: "Initiated",
                        pPhaseName: "ED Lab Panel",
                        pPhaseType: "SUBPHASE",
                        orders: [{
                            oOrderId: 6867049733,
                            oOrderMnemonic: "LA",
                            oOrderStatus: "Dispatched",
                            oOrderCatalogCd: 272253411,
                            oOrderSynonymId: 272253419,
                            oOrderCnt: 2
                        }, {
                            oOrderId: 6867049731,
                            oOrderMnemonic: "CBC",
                            oOrderStatus: "Dispatched",
                            oOrderCatalogCd: 2921414,
                            oOrderSynonymId: 2921415,
                            oOrderCnt: 1
                        }, {
                            oOrderId: 6867049751,
                            oOrderMnemonic: "C Blood",
                            oOrderStatus: "Dispatched", // Nursing workflow: Ordered but not collected yet
                            oOrderCatalogCd: 31713873,
                            oOrderSynonymId: 31713879,
                            oOrderCnt: 3
                        }]
                    }]
                }]
            },
            // Patient 2: HAS alert, NO screening (CLICKABLE CIRCLE)
            12345002: {
                PERSON_ID: 12345002,
                ENCNTR_ID: 12345002,
                PATIENT_NAME: "COUNTDOWN, Test B",
                UNIT: "ICU",
                ROOM_BED: "202-B",
                PATIENT_CLASS: "Inpatient",
                STATUS: "Critical",
                ACUITY: "Level 1",
                AGE: 58,
                GENDER: "Female",
                ADMISSION_DATE: "2025-09-28",
                ALERT_TYPE: "Sepsis Alert", // HAS alert
                SEPSIS_SCREEN_ASSESSMENT: "", // NO screening done - should show clickable circle
                timeZero: [{ // Time Zero: 45 minutes ago = 13:40 (2h 15m remaining)
                    type: "Diagnosis",
                    diagDtTmDisp: "09/29/25 13:40",
                    diagId: 11808191002,
                    diagDisplay: "Severe sepsis"
                }],
                powerplans: []
            },
            // Patient 3: Waiting Room patient NO SEPSIS (for WR count testing - Issue #57)
            12345003: {
                PERSON_ID: 12345003,
                ENCNTR_ID: 12345003,
                PATIENT_NAME: "COUNTDOWN, Test C",
                UNIT: "ER",
                ROOM_BED: "Waiting Room-",
                PATIENT_CLASS: "Emergency",
                STATUS: "Alert",
                ACUITY: "Level 2",
                AGE: 42,
                GENDER: "Male",
                ADMISSION_DATE: "2025-09-29",
                ALERT_TYPE: "", // NO alert
                SEPSIS_SCREEN_ASSESSMENT: "", // NO screening
                timeZero: [], // NO TIME ZERO - does NOT meet sepsis criteria
                powerplans: [] // NO PowerPlan
            },
            // Patient 4: Lactate ≥4.0, Perfusion NOT done (CLICKABLE CIRCLE TEST)
            // Patient 4: Severe Sepsis by DIAGNOSIS only (no alert) + Critical Lactate
            // Tests: Diagnosis triggers bundles, Critical lactate enables 6-hr bundle
            12345004: {
                PERSON_ID: 12345004,
                ENCNTR_ID: 12345004,
                PATIENT_NAME: "COUNTDOWN, Test D",
                UNIT: "ER",
                ROOM_BED: "ER-12",
                PATIENT_CLASS: "Emergency",
                STATUS: "Stable",
                ACUITY: "Level 2",
                AGE: 67,
                GENDER: "Female",
                ADMISSION_DATE: "2025-09-29",
                ALERT_TYPE: "", // NO ALERT - diagnosis only
                SEPSIS_SCREEN_ASSESSMENT: "", // NO SCREENING - diagnosis only
                LAST_SEPSIS_SCREEN: "09/29/25 12:35", // Time Zero from diagnosis
                SEPSIS_TIMER: "", // Will be calculated from Time Zero
                POWERPLAN_ORDERED: "N", // Not ordered yet
                LACTATE_ORDERED: "N",
                LACTATE_RESULT: 4.5, // Critical lactate - triggers 6-hr bundle
                BLOOD_CULTURES_ORDERED: "N",
                ANTIBIOTICS_ORDERED: "N",
                SEPSIS_FLUID_ORDERED: "N",
                REPEAT_LACTATE_ORDERED: "N",
                PERFUSION_ASSESSMENT: "N", // Should show as clickable
                SEPSIS_PRESSORS: "N",
                timeZero: [{ // Time Zero: 110 minutes ago = 12:35 (1h 10m remaining)
                    type: "Diagnosis",
                    diagDtTmDisp: "09/29/25 12:35",
                    diagId: 11808191004,
                    diagDisplay: "Severe sepsis"
                }],
                powerplans: [],
                screen: [],
                perfusion: [], // v20: No perfusion assessment (Issue #47)
                lactate: [],
                cultures: [],
                antibiotics: [  // v21: Enhanced with primaryMnemonic, catalogCd, orderId (from real Yeomans data)
                    {
                        orderId: 7301655209,
                        orderMnemonic: "cefepime 2,000 mg/10 ml vial",
                        primaryMnemonic: "cefepime",  // v21: Standardized name
                        catalogCd: 2752723,  // v21: Catalog code
                        powerplanPhase: "Ad-hoc",
                        orderStatusDisp: "Completed",
                        totalAdministrations: 1,
                        firstAdminDtTmDisp: "09/29/25 12:45",
                        administrations: [{
                            eventId: 8078613839,
                            adminDtTm: "2025-09-29T17:45:00.000",
                            adminDtTmDisp: "09/29/25 12:45",
                            adminDose: 2000,
                            adminDoseUnit: "mg",
                            adminRoute: "IV Push",
                            adminSite: "Arm, Left",
                            sequence: 1
                        }]
                    },
                    {
                        orderId: 7301653183,
                        orderMnemonic: "vancomycin",
                        primaryMnemonic: "vancomycin",  // v21: Same as orderMnemonic (tests conditional display)
                        catalogCd: 2770944,  // v21: Catalog code
                        powerplanPhase: "Ad-hoc",
                        orderStatusDisp: "Completed",
                        totalAdministrations: 1,
                        firstAdminDtTmDisp: "09/29/25 13:00",
                        administrations: [{
                            eventId: 8078613845,
                            adminDtTm: "2025-09-29T18:00:00.000",
                            adminDtTmDisp: "09/29/25 13:00",
                            adminDose: 1250,
                            adminDoseUnit: "mg",
                            adminRoute: "IV Piggyback",
                            adminSite: "Arm, Left",
                            sequence: 1
                        }]
                    }
                ],
                fluids: [],
                pressors: []
            },
            // Patient 5: Time Zero 135 minutes ago = 12:10 (45m remaining)
            12345005: {
                PERSON_ID: 12345005,
                ENCNTR_ID: 12345005,
                PATIENT_NAME: "COUNTDOWN, Test E",
                UNIT: "ICU",
                ROOM_BED: "301-C",
                PATIENT_CLASS: "Inpatient",
                STATUS: "Critical",
                ACUITY: "Level 1",
                AGE: 71,
                GENDER: "Male",
                ADMISSION_DATE: "2025-09-29",
                timeZero: [{ // Time Zero: 135 minutes ago = 12:10 (45m remaining)
                    type: "Diagnosis",
                    diagDtTmDisp: "09/29/25 12:10",
                    diagId: 11808191005,
                    diagDisplay: "Severe sepsis"
                }],
                powerplans: []
            },
            // Patient 6: Time Zero 165 minutes ago = 11:40 (15m remaining)
            12345006: {
                PERSON_ID: 12345006,
                ENCNTR_ID: 12345006,
                PATIENT_NAME: "COUNTDOWN, Test F",
                UNIT: "ER",
                ROOM_BED: "ER-08",
                PATIENT_CLASS: "Emergency",
                STATUS: "Alert",
                ACUITY: "Level 2",
                AGE: 55,
                GENDER: "Female",
                ADMISSION_DATE: "2025-09-29",
                timeZero: [{ // Time Zero: 165 minutes ago = 11:40 (15m remaining)
                    type: "Diagnosis",
                    diagDtTmDisp: "09/29/25 11:40",
                    diagId: 11808191006,
                    diagDisplay: "Severe sepsis"
                }],
                powerplans: []
            },
            // Patient 7: Time Zero 175 minutes ago = 11:30 (5m remaining - URGENT!)
            12345007: {
                PERSON_ID: 12345007,
                ENCNTR_ID: 12345007,
                PATIENT_NAME: "COUNTDOWN, Test G",
                UNIT: "ICU",
                ROOM_BED: "302-A",
                PATIENT_CLASS: "Inpatient",
                STATUS: "Critical",
                ACUITY: "Level 1",
                AGE: 63,
                GENDER: "Male",
                ADMISSION_DATE: "2025-09-29",
                timeZero: [{ // Time Zero: 175 minutes ago = 11:30 (5m remaining)
                    type: "Diagnosis",
                    diagDtTmDisp: "09/29/25 11:30",
                    diagId: 11808191007,
                    diagDisplay: "Severe sepsis"
                }],
                powerplans: []
            },
            // Patient 8: Time Zero 210 minutes ago = 10:55 (OVERDUE by 30m)
            12345008: {
                PERSON_ID: 12345008,
                ENCNTR_ID: 12345008,
                PATIENT_NAME: "COUNTDOWN, Test H",
                UNIT: "ER",
                ROOM_BED: "ER-03",
                PATIENT_CLASS: "Emergency",
                STATUS: "Alert",
                ACUITY: "Level 2",
                AGE: 48,
                GENDER: "Female",
                ADMISSION_DATE: "2025-09-29",
                timeZero: [{ // Time Zero: 210 minutes ago = 10:55 (OVERDUE by 30m)
                    type: "Diagnosis",
                    diagDtTmDisp: "09/29/25 10:55",
                    diagId: 11808191008,
                    diagDisplay: "Severe sepsis"
                }],
                powerplans: []
            },

            // Patient 9: NO SEPSIS INDICATION - Test for Issue #31 and #57 (ER bed, no sepsis)
            12345009: {
                PERSON_ID: 12345009,
                ENCNTR_ID: 12345009,
                PATIENT_NAME: "NOSEPSIS, Test Control",
                UNIT: "ER",
                ROOM_BED: "ER-20",
                PATIENT_CLASS: "Emergency",
                STATUS: "Stable",
                ACUITY: "Level 3",
                AGE: 55,
                GENDER: "Male",
                ADMISSION_DATE: "2025-10-22",
                ALERT_TYPE: "", // NO ALERT
                SEPSIS_SCREEN_ASSESSMENT: "", // NO SCREENING
                POWERPLAN_ORDERED: "N", // NO POWERPLAN
                LACTATE_ORDERED: "N",
                LACTATE_RESULT: 1.2, // Normal lactate (should still display in Lac 1 Rslt column)
                BLOOD_CULTURES_ORDERED: "N",
                ANTIBIOTICS_ORDERED: "N",
                SEPSIS_FLUID_ORDERED: "N",
                REPEAT_LACTATE_ORDERED: "N",
                PERFUSION_ASSESSMENT: "N",
                SEPSIS_PRESSORS: "N",
                timeZero: [],
                powerplans: [],
                screen: [],
                lactate: [],
                cultures: [],
                antibiotics: [],
                fluids: [],
                pressors: []
            },

            // List B Patients - Different patients with different data
            22345001: {
                PERSON_ID: 22345001,
                ENCNTR_ID: 22345001,
                PATIENT_NAME: "SMITH, John B",
                UNIT: "ER",
                ROOM_BED: "ER-10",
                PATIENT_CLASS: "Emergency",
                STATUS: "Stable",
                ACUITY: "Level 2",
                AGE: 72,
                GENDER: "Male",
                ADMISSION_DATE: "2025-09-29",
                ALERT_TYPE: "Severe Sepsis", // HAS alert
                SEPSIS_SCREEN_ASSESSMENT: "Septic Shock/Severe Sepsis with hypotension has been confirm", // RED with !! (Issue #41)
                POWERPLAN_ORDERED: "Y",
                LACTATE_ORDERED: "Y",
                LACTATE_RESULT: 3.1,
                BLOOD_CULTURES_ORDERED: "Y",
                ANTIBIOTICS_ORDERED: "Y",
                SEPSIS_FLUID_ORDERED: "Y",
                timeZero: [{
                    type: "Alert",
                    diagDtTmDisp: "09/29/25 13:30",
                    diagId: 22808191001,
                    diagDisplay: "Sepsis alert"
                }],
                powerplans: []
            },

            22345002: {
                PERSON_ID: 22345002,
                ENCNTR_ID: 22345002,
                PATIENT_NAME: "JOHNSON, Mary B",
                UNIT: "Med",
                ROOM_BED: "301-B",
                PATIENT_CLASS: "Inpatient",
                STATUS: "Stable",
                ACUITY: "Level 3",
                AGE: 45,
                GENDER: "Female",
                ADMISSION_DATE: "2025-09-28",
                ALERT_TYPE: "Severe Sepsis", // HAS alert
                SEPSIS_SCREEN_ASSESSMENT: "Severe Sepsis/Septic Shock ruled out - this patient has no e", // GREEN icon - ruled out (Issue #41)
                POWERPLAN_ORDERED: "N",
                LACTATE_ORDERED: "Pend",
                LACTATE_RESULT: "",
                BLOOD_CULTURES_ORDERED: "Pend",
                ANTIBIOTICS_ORDERED: "N",
                SEPSIS_FLUID_ORDERED: "N",
                timeZero: [{
                    type: "Alert",
                    diagDtTmDisp: "09/29/25 14:00",
                    diagId: 22808191002,
                    diagDisplay: "Sepsis alert"
                }],
                powerplans: []
            },

            22345003: {
                PERSON_ID: 22345003,
                ENCNTR_ID: 22345003,
                PATIENT_NAME: "WILLIAMS, Robert B",
                UNIT: "ICU",
                ROOM_BED: "210-A",
                PATIENT_CLASS: "Inpatient",
                STATUS: "Critical",
                ACUITY: "Level 1",
                AGE: 68,
                GENDER: "Male",
                ADMISSION_DATE: "2025-09-27",
                ALERT_TYPE: "Severe Sepsis", // HAS alert
                SEPSIS_SCREEN_ASSESSMENT: "I cannot determine the presence of severe sepsis or septic s", // YELLOW icon - indeterminate (Issue #41)
                POWERPLAN_ORDERED: "Y",
                LACTATE_ORDERED: "Y",
                LACTATE_RESULT: 4.8,
                BLOOD_CULTURES_ORDERED: "Y",
                ANTIBIOTICS_ORDERED: "Y",
                SEPSIS_FLUID_ORDERED: "Y",
                REPEAT_LACTATE_ORDERED: "Y",
                PERFUSION_ASSESSMENT: "Y",
                PRESSORS_ORDERED: "Y",
                timeZero: [{
                    type: "Diagnosis",
                    diagDtTmDisp: "09/29/25 12:45",
                    diagId: 22808191003,
                    diagDisplay: "Severe sepsis with shock"
                }],
                powerplans: []
            },

            22345004: {
                PERSON_ID: 22345004,
                ENCNTR_ID: 22345004,
                PATIENT_NAME: "BROWN, Patricia B",
                UNIT: "Med",
                ROOM_BED: "304-A",
                PATIENT_CLASS: "Inpatient",
                STATUS: "Stable",
                ACUITY: "Level 2",
                AGE: 59,
                GENDER: "Female",
                ADMISSION_DATE: "2025-09-29",
                ALERT_TYPE: "Severe Sepsis", // HAS alert
                SEPSIS_SCREEN_ASSESSMENT: "Septic Shock/Severe Sepsis with hypotension has been confirm", // RED with !! (Issue #41)
                POWERPLAN_ORDERED: "Y",
                LACTATE_ORDERED: "Y",
                LACTATE_RESULT: 2.1,
                BLOOD_CULTURES_ORDERED: "Y",
                ANTIBIOTICS_ORDERED: "Y",
                SEPSIS_FLUID_ORDERED: "Y",
                timeZero: [{
                    type: "Alert",
                    diagDtTmDisp: "09/29/25 13:15",
                    diagId: 22808191004,
                    diagDisplay: "Sepsis alert"
                }],
                perfusion: [], // v20: No perfusion assessment (Issue #47)
                powerplans: []
            },

            22345005: {
                PERSON_ID: 22345005,
                ENCNTR_ID: 22345005,
                PATIENT_NAME: "DAVIS, Michael B",
                UNIT: "ER",
                ROOM_BED: "ER-15",
                PATIENT_CLASS: "Emergency",
                STATUS: "Alert",
                ACUITY: "Level 2",
                AGE: 34,
                GENDER: "Male",
                ADMISSION_DATE: "2025-09-29",
                ALERT_TYPE: "Severe Sepsis", // HAS alert
                SEPSIS_SCREEN_ASSESSMENT: "Severe Sepsis has been confirmed in this patient", // RED with ! (Issue #41)
                POWERPLAN_ORDERED: "Y",
                LACTATE_ORDERED: "Y",
                LACTATE_RESULT: 1.8,
                BLOOD_CULTURES_ORDERED: "Y",
                ANTIBIOTICS_ORDERED: "Pend",
                SEPSIS_FLUID_ORDERED: "Pend",
                timeZero: [{
                    type: "Alert",
                    diagDtTmDisp: "09/29/25 14:10",
                    diagId: 22808191005,
                    diagDisplay: "Sepsis alert"
                }],
                perfusion: [], // v20: No perfusion assessment (Issue #47)
                powerplans: []
            },

            22345006: {
                PERSON_ID: 22345006,
                ENCNTR_ID: 22345006,
                PATIENT_NAME: "MILLER, Linda B",
                UNIT: "ICU",
                ROOM_BED: "215-B",
                PATIENT_CLASS: "Inpatient",
                STATUS: "Critical",
                ACUITY: "Level 1",
                AGE: 78,
                GENDER: "Female",
                ADMISSION_DATE: "2025-09-26",
                SEPSIS_SCREEN_ASSESSMENT: "Severe Sepsis",
                POWERPLAN_ORDERED: "Y",
                LACTATE_ORDERED: "Y",
                LACTATE_RESULT: 5.2,
                BLOOD_CULTURES_ORDERED: "Y",
                ANTIBIOTICS_ORDERED: "Y",
                SEPSIS_FLUID_ORDERED: "Y",
                REPEAT_LACTATE_ORDERED: "Y",
                PERFUSION_ASSESSMENT: "Y",
                PRESSORS_ORDERED: "Y",
                timeZero: [{
                    type: "Diagnosis",
                    diagDtTmDisp: "09/29/25 11:30",
                    diagId: 22808191006,
                    diagDisplay: "Severe sepsis with shock"
                }],
                powerplans: []
            }
        };
        
        // Get encounter IDs from parameters
        const encounterIds = Array.isArray(parameters) ? parameters : [parameters[0]];
        
        // Map encounter IDs to patient data
        const patients = encounterIds.map(encId => patientDataMap[encId]).filter(p => p !== undefined);

        return {
            drec: {
                patientCnt: patients.length,
                patient_list_id: 0,
                name: "Mock Patient List",
                description: "Mock patient demographics",
                patients: patients,
                status_data: {
                    status: "S",
                    message: `Successfully retrieved ${patients.length} patients`
                }
            }
        };
    };
    
    /**
     * Mock user info matching respiratory MPage REC format
     */
    XMLCclRequestSimulator.prototype.getMockUserInfo = function(parameters) {
        // Multiple mock users in respiratory MPage REC format for testing different positions
        const mockUsers = {
            8333417: { // Default DBA user (matches respiratory MPage format)
                "REC": {
                    "USER_ID": 8333417.000000,
                    "USER_NAME": "Demo, DBA User",
                    "USER_POSITION": "P1 DBA",
                    "CUR_NODE": "devnode01",
                    "CUR_USER": "D_DEMO",
                    "CUR_SERVER": "100"
                }
            },
            8333418: { // Nurse user
                "REC": {
                    "USER_ID": 8333418.000000,
                    "USER_NAME": "Demo, Nurse User",
                    "USER_POSITION": "Registered Nurse",
                    "CUR_NODE": "devnode01",
                    "CUR_USER": "D_NURSE",
                    "CUR_SERVER": "100"
                }
            },
            8333419: { // Senior DBA variant
                "REC": {
                    "USER_ID": 8333419.000000,
                    "USER_NAME": "Demo, Admin User",
                    "USER_POSITION": "Database Administrator",
                    "CUR_NODE": "devnode01", 
                    "CUR_USER": "D_ADMIN",
                    "CUR_SERVER": "100"
                }
            }
        };
        
        // Return specific user or default DBA - FAIL-SECURE for unknown users
        const requestedPersonId = parameters && parameters[1] ? parseFloat(parameters[1]) : 8333417;
        
        // SECURITY: Do NOT fallback to DBA for unknown users
        if (requestedPersonId !== 8333417 && !mockUsers[requestedPersonId]) {
            console.warn(`[XMLCclRequestSimulator] SECURITY: Unknown user ${requestedPersonId} requested - returning null for fail-secure behavior`);
            return {
                "REC": null,  // Explicitly null for unknown users
                "ERROR": {
                    "status": "E",
                    "message": `User ${requestedPersonId} not found - access denied`
                }
            };
        }
        
        const userData = mockUsers[requestedPersonId] || mockUsers[8333417];
        console.log(`[XMLCclRequestSimulator] Returning user data for person_id: ${requestedPersonId}`);
        
        return userData;
    };
    
    // Expose to global scope
    window.XMLCclRequestSimulator = XMLCclRequestSimulator;
    
})(window);