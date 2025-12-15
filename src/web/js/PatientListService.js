// Patient List Service
(function(window) {
    // Embedded mock data with generic patient lists
    const MOCK_PATIENT_LISTS = {
        rpatlists: {
            applicationId: 0.000000,
            prsnlId: 0.000000,
            qual: [
                {"viewSeq": 1, "patientListId": 1001.000000, "name": "Demo Patient List A"},
                {"viewSeq": 2, "patientListId": 1002.000000, "name": "Demo Patient List B"}
            ]
        }
    };

    /**
     * Creates a new PatientListService
     * Uses global SIMULATOR_CONFIG to determine simulator vs production mode
     * @param {boolean} debugMode - Whether to enable debug logging
     * @param {string|number} personId - Personnel ID override to use for fetching patient lists 
     */
    function PatientListService(debugMode = true, personId = null) {
        this.debugMode = debugMode;
        this.debugMessages = [];
        
        // Default personId used in simulator mode
        this.defaultPersonId = 8333417;   // Default test user ID
        
        // Override personId if provided
        this.overridePrsnlID = personId;
        
        // Debug initialization with global configuration
        const isSimulator = window.SIMULATOR_CONFIG?.enabled;
        if (this.overridePrsnlID) {
            this._logDebug(`PatientListService initialized with override personId: ${this.overridePrsnlID}`);
        } else if (isSimulator) {
            this._logDebug(`PatientListService initialized in simulator mode with default personId: ${this.defaultPersonId} (SIMULATOR_CONFIG.enabled = true)`);
        } else {
            this._logDebug(`PatientListService initialized in production mode using $USR_PersonId$ variable (SIMULATOR_CONFIG.enabled = false)`);
        }
    }

    /**
     * Log debug messages using Eruda console
     */
    PatientListService.prototype._logDebug = function(message, type = 'log') {
        if (this.debugMode) {
            console[type](`[PatientListService] ${message}`);
        }
    };

    /**
     * Fetch patient lists from CCL or simulator
     * @returns {Promise<Array>} - Array of patient lists
     */
    PatientListService.prototype.getPatientLists = async function() {
        const isSimulator = window.SIMULATOR_CONFIG?.enabled;
        this._logDebug(`Fetching patient lists. Simulator Mode: ${isSimulator}`);

        try {
            let data;
            
            if (isSimulator) {
                // Load mock data in simulator mode
                this._logDebug('Using simulator mode for patient lists (SIMULATOR_CONFIG.enabled = true)');
                data = await this.loadMockData();
                this._logDebug('Mock patient lists loaded successfully');
            } else {
                // Use CCL in production mode
                this._logDebug('Using production mode for patient lists (SIMULATOR_CONFIG.enabled = false)');
                
                if (typeof window.sendCclRequest === 'function') {
                    // Priority: 1) Impersonated user, 2) Service override, 3) Current Cerner user
                    const effectivePersonId = 
                        (window.USER_CONTEXT_CONFIG && window.USER_CONTEXT_CONFIG.impersonatePersonId) ||
                        this.overridePrsnlID || 
                        '$USR_PersonId$';
                        
                    this._logDebug(`Using personnel ID: ${effectivePersonId}`);
                    
                    const cclResponse = await window.sendCclRequest(
                        '1_cust_mp_gen_get_plists',
                        ['MINE', effectivePersonId],
                        {
                            debug: this.debugMode,
                            timeout: 90000
                        }
                    );
                    
                    data = cclResponse;
                } else {
                    throw new Error('SendCclRequest not available in Millennium mode');
                }
            }

            return this.parsePatientListData(data);

        } catch (error) {
            this._logDebug(`Error fetching patient lists: ${error.message}`, 'error');
            throw error;
        }
    };

    /**
     * Get patients for a specific patient list
     * @param {string|number} listId - Patient list ID
     * @returns {Promise<Array>} - Array of patient data
     */
    PatientListService.prototype.getPatientListPatients = async function(listId) {
        this._logDebug(`Getting patients for list ID: ${listId}`);
        console.trace('getPatientListPatients called from:'); // Stack trace to find caller
        
        try {
            const isSimulator = window.SIMULATOR_CONFIG?.enabled;
            
            if (isSimulator) {
                // Use XMLCclRequestSimulator for consistent mock data
                if (window.XMLCclRequestSimulator) {
                    const simulator = new window.XMLCclRequestSimulator();
                    
                    // Step 1: Get patient IDs
                    const patientIdsResponse = await simulator.simulateRequest('1_cust_mp_gen_get_pids', ['MINE', listId]);
                    
                    // Step 2: Get patient demographics
                    if (patientIdsResponse && patientIdsResponse.ptlstencntrReply && patientIdsResponse.ptlstencntrReply.patients && patientIdsResponse.ptlstencntrReply.patients.length > 0) {
                        // Extract encounter IDs from the patient list response
                        const encounterIds = patientIdsResponse.ptlstencntrReply.patients.map(p => p.encntrId);
                        this._logDebug(`Got encounter IDs for list ${listId}: ${encounterIds.join(', ')}`);
                        
                        const patientDataResponse = await simulator.simulateRequest('1_cust_mp_gen_get_pdata', encounterIds);
                        this._logDebug(`Got ${patientDataResponse.drec.patients.length} patients for list ${listId}`);
                        this._logDebug(`First patient: ${patientDataResponse.drec.patients[0]?.PATIENT_NAME}`);
                        return patientDataResponse.drec.patients || [];
                    }
                }
                
                // Fallback to old method if simulator not available
                return this.generateMockPatientData(listId);
            } else {
                // Call CCL to get actual patient data
                if (typeof window.sendCclRequest === 'function') {
                    // Step 1: Get patient IDs from the list (dispatcher call)
                    const patientIdsResponse = await window.sendCclRequest(
                        '1_cust_mp_gen_get_pids',
                        ['MINE', listId],
                        {
                            debug: this.debugMode,
                            timeout: 90000
                        }
                    );
                    
                    
                    // Step 2: Extract encounter IDs from patient list response and get patient demographics
                    if (patientIdsResponse && patientIdsResponse.ptlstencntrReply && patientIdsResponse.ptlstencntrReply.patients) {
                        // Extract encounter IDs from the patients array
                        const encounterIds = patientIdsResponse.ptlstencntrReply.patients
                            .map(patient => patient.encntrId)  // JSON uses camelCase "encntrId"
                            .filter(id => id && id > 0);
                            
                        this._logDebug(`Extracted ${encounterIds.length} encounter IDs from patient list response`);
                        
                        if (encounterIds.length > 0) {
                            // Format encounter IDs with value() function (respiratory MPage pattern)
                            const encounterIdsForCcl = `value(${encounterIds.join(',')})`;
                            this._logDebug(`Formatted encounter IDs for CCL: ${encounterIdsForCcl}`);
                            
                            // Use respiratory MPage parameter pattern with rawStart
                            const patientDataParams = ["MINE", encounterIdsForCcl];
                            patientDataParams.rawStart = 1; // Don't quote the value() function
                            
                            const patientDataResponse = await window.sendCclRequest(
                                '1_cust_mp_gen_get_pdata',
                                patientDataParams,
                                {
                                    debug: this.debugMode,
                                    timeout: 90000
                                }
                            );
                            
                            // Raw JSON response for data structure analysis
                            console.log('🏥 RAW CERNER JSON RESPONSE:', patientDataResponse);

                            // v23: Log CCL program version info for debugging (PROMINENT BANNER)
                            if (patientDataResponse && patientDataResponse.drec) {
                                console.log('%c═══════════════════════════════════════════════════════════', 'color: #00ff00; font-weight: bold; font-size: 14px;');
                                console.log('%c🔧 CCL PROGRAM VERSION INFO', 'color: #00ff00; font-weight: bold; font-size: 16px;');
                                console.log('%c═══════════════════════════════════════════════════════════', 'color: #00ff00; font-weight: bold; font-size: 14px;');
                                console.log('%cProgram: ' + (patientDataResponse.drec.program_version || 'Unknown'), 'color: #00ff00; font-weight: bold; font-size: 14px;');
                                console.log('%cBuild Date: ' + (patientDataResponse.drec.program_build_date || 'Unknown'), 'color: #00ff00; font-weight: bold; font-size: 14px;');
                                console.log('%cGit Branch: ' + (patientDataResponse.drec.program_git_branch || 'Unknown'), 'color: #00ff00; font-weight: bold; font-size: 14px;');
                                console.log('%c═══════════════════════════════════════════════════════════', 'color: #00ff00; font-weight: bold; font-size: 14px;');
                            }

                            if (patientDataResponse && patientDataResponse.drec && patientDataResponse.drec.patients) {
                                return patientDataResponse.drec.patients;
                            } else {
                                this._logDebug('Patient data response structure:', 'info');
                                console.log('[PatientListService] PATIENT DATA RESPONSE:', JSON.stringify(patientDataResponse, null, 2));
                                throw new Error('Invalid patient data format received from get_pdata - expecting drec.patients');
                            }
                        } else {
                            this._logDebug('No valid encounter IDs found in patient list', 'warn');
                            return [];
                        }
                    } else {
                        this._logDebug('Invalid patient list response format', 'warn');
                        return [];
                    }
                } else {
                    throw new Error('SendCclRequest not available in Millennium mode');
                }
            }
        } catch (error) {
            this._logDebug(`Error getting patients for list ${listId}: ${error.message}`, 'error');
            
            if (this.allowMockFallback) {
                this._logDebug('Falling back to mock patient data due to error');
                return this.generateMockPatientData(listId);
            } else {
                throw error;
            }
        }
    };

    /**
     * Load mock data
     */
    PatientListService.prototype.loadMockData = async function() {
        // Simulate network delay
        await new Promise(resolve => setTimeout(resolve, 100));
        return MOCK_PATIENT_LISTS;
    };

    /**
     * Parse patient list data
     */
    PatientListService.prototype.parsePatientListData = function(data) {
        try {
            if (!data || !data.rpatlists || !data.rpatlists.qual) {
                this._logDebug('No patient lists found in data', 'warn');
                return [];
            }

            const patientLists = data.rpatlists.qual.map(list => ({
                patientListId: list.patientListId,
                name: list.name,
                viewSeq: list.viewSeq
            }));

            this._logDebug(`Parsed ${patientLists.length} patient lists`);
            return patientLists;

        } catch (error) {
            this._logDebug(`Error parsing patient list data: ${error.message}`, 'error');
            return [];
        }
    };

    /**
     * Generate mock patient data for simulator mode
     */
    PatientListService.prototype.generateMockPatientData = function(listId) {
        const mockPatients = [
            {
                PATIENT_NAME: "ZZZTEST, John Doe",
                PERSON_ID: 88001,
                ENCNTR_ID: 99001,
                UNIT: "ICU",
                ROOM_BED: "201-A",
                PATIENT_CLASS: "Inpatient",
                STATUS: "Critical",
                ACUITY: "Level 1",
                AGE: 65,
                GENDER: "Male",
                ADMISSION_DATE: "2025-09-01"
            },
            {
                PATIENT_NAME: "ZZZTEST, Jane Smith",
                PERSON_ID: 88002,
                ENCNTR_ID: 99002,
                UNIT: "ICU",
                ROOM_BED: "202-B",
                PATIENT_CLASS: "Inpatient",
                STATUS: "Stable",
                ACUITY: "Level 2",
                AGE: 72,
                GENDER: "Female",
                ADMISSION_DATE: "2025-08-30"
            },
            {
                PATIENT_NAME: "ZZZTEST, Robert Johnson",
                PERSON_ID: 88003,
                ENCNTR_ID: 99003,
                UNIT: "3W",
                ROOM_BED: "315-A",
                PATIENT_CLASS: "Inpatient",
                STATUS: "Alert",
                ACUITY: "Level 2",
                AGE: 58,
                GENDER: "Male",
                ADMISSION_DATE: "2025-09-02"
            },
            {
                PATIENT_NAME: "ZZZTEST, Mary Williams",
                PERSON_ID: 88004,
                ENCNTR_ID: 99004,
                UNIT: "2N",
                ROOM_BED: "245-B",
                PATIENT_CLASS: "Inpatient",
                STATUS: "Stable",
                ACUITY: "Level 3",
                AGE: 43,
                GENDER: "Female",
                ADMISSION_DATE: "2025-08-31"
            },
            {
                PATIENT_NAME: "ZZZTEST, Michael Brown",
                PERSON_ID: 88005,
                ENCNTR_ID: 99005,
                UNIT: "ER",
                ROOM_BED: "ER-05",
                PATIENT_CLASS: "Emergency",
                STATUS: "Alert",
                ACUITY: "Level 2",
                AGE: 29,
                GENDER: "Male",
                ADMISSION_DATE: "2025-09-02"
            },
            {
                PATIENT_NAME: "ZZZTEST, Sarah Davis",
                PERSON_ID: 88006,
                ENCNTR_ID: 99006,
                UNIT: "ER",
                ROOM_BED: "ER-12",
                PATIENT_CLASS: "Emergency",
                STATUS: "Stable",
                ACUITY: "Level 3",
                AGE: 34,
                GENDER: "Female",
                ADMISSION_DATE: "2025-09-02"
            }
        ];

        // Filter based on list ID or ER tracking group to simulate different lists
        const listIdNum = parseInt(listId) || 0;

        // ER tracking group codes (Issue #78 ER units)
        if (listId === '271365867.00' || listId === 271365867) {
            // General Hospital ER - Return ICU and ER patients
            return mockPatients.filter(p => p.UNIT === 'ICU' || p.UNIT === 'ER');
        } else if (listId === '28309431.00' || listId === 28309431) {
            // Memorial Hospital - Return different mix (2N, 3W units)
            return mockPatients.filter(p => p.UNIT === '2N' || p.UNIT === '3W');
        } else if (listId === '271366149.00' || listId === 271366149) {
            // Teays Valley - Return ER only
            return mockPatients.filter(p => p.UNIT === 'ER');
        } else if (listId === '271366419.00' || listId === 271366419) {
            // Women and Children's - Return ICU only
            return mockPatients.filter(p => p.UNIT === 'ICU');
        } else if (listId === '8800251397.00' || listId === 8800251397) {
            // Greenbrier - Return 2N only
            return mockPatients.filter(p => p.UNIT === '2N');
        } else if (listId === '9799324931.00' || listId === 9799324931) {
            // Plateau - Return 3W only
            return mockPatients.filter(p => p.UNIT === '3W');
        }

        // Patient list IDs
        switch (listIdNum) {
            case 1001: // ICU Patients
                return mockPatients.filter(p => p.UNIT === 'ICU' || p.UNIT === '3W');
            case 1002: // Emergency Department
                return mockPatients.filter(p => p.UNIT === 'ER');
            case 1003: // Medical Ward
                return mockPatients.filter(p => p.UNIT === '2N' || p.UNIT === '3W');
            case 1004: // Surgical Ward
                return mockPatients.filter(p => p.UNIT === '3W');
            default:
                return mockPatients;
        }
    };

    /**
     * Get patients for a specific ER unit by tracking group
     * Issue #78: Shared ER Patient Lists
     * @param {string} trackingGroupCd - ED tracking group code (e.g., 271365867.00 for General)
     * @returns {Promise<Array>} - Array of patient data
     */
    PatientListService.prototype.getERUnitPatients = async function(trackingGroupCd) {
        this._logDebug(`Getting ER patients for tracking group: ${trackingGroupCd}`);

        try {
            const isSimulator = window.SIMULATOR_CONFIG?.enabled;

            if (isSimulator) {
                // Use mock data in simulator mode with delay (to see loading message)
                this._logDebug('Simulator mode: Using mock ER patient data with delay');
                return new Promise((resolve) => {
                    setTimeout(() => {
                        resolve(this.generateMockPatientData(trackingGroupCd));
                    }, 100); // 100ms delay (production CCL will have natural delays)
                });
            } else {
                // Call ER census CCL in production
                if (typeof window.sendCclRequest === 'function') {
                    // Step 1: Get encounter IDs from ER tracking board
                    // Use rawStart to prevent quoting the tracking group code (float parameter)
                    const censusParams = ['MINE', trackingGroupCd];
                    censusParams.rawStart = 1;  // Don't quote parameter 2 (tracking group is float, not string)

                    const erCensusResponse = await window.sendCclRequest(
                        '1_cust_mp_gen_get_er_encntrs',
                        censusParams,
                        {
                            debug: this.debugMode,
                            timeout: 90000
                        }
                    );

                    this._logDebug('ER Census response received');
                    console.log('[PatientListService] ER Census data:', erCensusResponse);

                    // Step 2: Extract encounter IDs (structure: {erec: {patients: [...]}})
                    if (erCensusResponse && erCensusResponse.erec && erCensusResponse.erec.patients) {
                        const encounterIds = erCensusResponse.erec.patients
                            .map(patient => patient.encntrid)  // Lowercase from CCL
                            .filter(id => id && id > 0);

                        this._logDebug(`Extracted ${encounterIds.length} encounter IDs from ER tracking board`);

                        if (encounterIds.length > 0) {
                            // Step 3: Get full patient data (reuse existing logic)
                            // Format encounter IDs with value() function (same as patient list pattern)
                            const encounterIdsForCcl = `value(${encounterIds.join(',')})`;
                            this._logDebug(`Formatted encounter IDs for CCL: ${encounterIdsForCcl}`);

                            // Use respiratory MPage parameter pattern with rawStart
                            const patientDataParams = ["MINE", encounterIdsForCcl];
                            patientDataParams.rawStart = 1; // Don't quote the value() function

                            const patientDataResponse = await window.sendCclRequest(
                                '1_cust_mp_gen_get_pdata',
                                patientDataParams,
                                {
                                    debug: this.debugMode,
                                    timeout: 90000
                                }
                            );

                            this._logDebug('Patient data response received');
                            console.log('[PatientListService] Patient data:', patientDataResponse);

                            if (patientDataResponse && patientDataResponse.drec && patientDataResponse.drec.patients) {
                                return patientDataResponse.drec.patients;
                            } else {
                                throw new Error('Invalid patient data format received from get_pdata');
                            }
                        } else {
                            this._logDebug('No valid encounter IDs found in ER tracking board', 'warn');
                            return [];
                        }
                    } else {
                        this._logDebug('Invalid ER census response format', 'warn');
                        return [];
                    }
                } else {
                    throw new Error('SendCclRequest not available in Millennium mode');
                }
            }
        } catch (error) {
            this._logDebug(`Error getting ER patients for tracking group ${trackingGroupCd}: ${error.message}`, 'error');
            throw error;
        }
    };

    // Expose PatientListService to global scope
    window.PatientListService = PatientListService;

})(window);