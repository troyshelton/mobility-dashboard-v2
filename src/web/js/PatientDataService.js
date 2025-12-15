// Patient Data Service - Handles patient data processing and formatting
(function(window) {
    'use strict';
    
    /**
     * PatientDataService - Processes and formats patient data
     * Uses global SIMULATOR_CONFIG to determine simulator vs production mode
     * @param {boolean} debugMode - Whether to enable debug logging
     */
    function PatientDataService(debugMode = true) {
        this.debugMode = debugMode;
        this.debugMessages = [];
        this.lastRawCCLResponse = null; // Store raw CCL response for debugging

        if (this.debugMode) {
            const isSimulator = window.SIMULATOR_CONFIG?.enabled;
            this._logDebug(`PatientDataService initialized in ${isSimulator ? 'simulator' : 'production'} mode (SIMULATOR_CONFIG.enabled = ${isSimulator})`);
        }
    }
    
    /**
     * Log debug messages using Eruda console
     */
    PatientDataService.prototype._logDebug = function(message, type = 'log') {
        if (this.debugMode) {
            switch(type) {
                case 'error':
                    console.error(`[PatientDataService] ${message}`);
                    break;
                case 'warn':
                    console.warn(`[PatientDataService] ${message}`);
                    break;
                case 'info':
                    console.info(`[PatientDataService] ${message}`);
                    break;
                case 'debug':
                    if (console.debug) {
                        console.debug(`[PatientDataService] ${message}`);
                    } else {
                        console.log(`[PatientDataService] ${message}`);
                    }
                    break;
                default:
                    console.log(`[PatientDataService] ${message}`);
            }
        }
    };
    
    /**
     * Process patient data with case-insensitive field mapping
     * @param {Array} rawData - Raw patient data from CCL
     * @returns {Array} - Processed patient data
     */
    PatientDataService.prototype.processPatientData = function(rawData) {
        if (!Array.isArray(rawData)) {
            this._logDebug('Invalid patient data format: expected array', 'warn');
            return [];
        }

        // Store raw response for debugging (Issue #31 debugging)
        this.lastRawCCLResponse = JSON.parse(JSON.stringify(rawData)); // Deep copy
        console.log('📡 RAW CCL RESPONSE stored. Access via: PatientListApp.services.patientData.lastRawCCLResponse');

        this._logDebug(`Processing ${rawData.length} patient records`);

        return rawData.map((patient, index) => {
            try {
                return this.createCaseInsensitiveObject(patient);
            } catch (error) {
                this._logDebug(`Error processing patient record ${index}: ${error.message}`, 'error');
                return patient; // Return original if processing fails
            }
        });
    };
    
    /**
     * Create case-insensitive object for patient data
     * Handles both camelCase and UPPERCASE_WITH_UNDERSCORES formats
     * @param {Object} originalObject - Original patient object
     * @returns {Object} - Case-insensitive patient object
     */
    PatientDataService.prototype.createCaseInsensitiveObject = function(originalObject) {
        if (!originalObject || typeof originalObject !== 'object') {
            return originalObject;
        }
        
        const processedObject = {};
        const keyMap = {};
        
        // Create mapping of lowercase keys to original keys
        Object.keys(originalObject).forEach(key => {
            const lowerKey = key.toLowerCase();
            keyMap[lowerKey] = key;
            processedObject[key] = originalObject[key];
        });
        
        // Add common field mappings for patient demographics
        const fieldMappings = {
            'patient_name': ['PATIENT_NAME', 'patientName', 'name', 'NAME'],
            'unit': ['UNIT', 'unit', 'NURSING_UNIT', 'nursingUnit'],
            'room_bed': ['ROOM_BED', 'roomBed', 'ROOM', 'room', 'BED', 'bed'],
            'patient_class': ['PATIENT_CLASS', 'patientClass', 'CLASS', 'class'],
            'age': ['AGE', 'age', 'PATIENT_AGE', 'patientAge'],
            'gender': ['GENDER', 'gender', 'SEX', 'sex'],
            'admission_date': ['ADMISSION_DATE', 'admissionDate', 'ADMIT_DATE', 'admitDate']
        };
        
        // Apply field mappings
        Object.keys(fieldMappings).forEach(standardField => {
            const possibleKeys = fieldMappings[standardField];
            
            for (const possibleKey of possibleKeys) {
                if (originalObject.hasOwnProperty(possibleKey)) {
                    processedObject[standardField.toUpperCase()] = originalObject[possibleKey];
                    break;
                }
            }
        });
        
        return processedObject;
    };
    
    /**
     * Validate patient data
     * @param {Array} patientData - Patient data array
     * @returns {Object} - Validation result
     */
    PatientDataService.prototype.validatePatientData = function(patientData) {
        const result = {
            isValid: true,
            errors: [],
            warnings: [],
            recordCount: 0
        };
        
        if (!Array.isArray(patientData)) {
            result.isValid = false;
            result.errors.push('Patient data must be an array');
            return result;
        }
        
        result.recordCount = patientData.length;
        
        // Check each patient record
        patientData.forEach((patient, index) => {
            if (!patient || typeof patient !== 'object') {
                result.errors.push(`Record ${index}: Invalid patient object`);
                result.isValid = false;
                return;
            }
            
            // Check for required fields
            const requiredFields = ['PATIENT_NAME'];
            const missingFields = requiredFields.filter(field => 
                !patient[field] && !patient[field.toLowerCase()]
            );
            
            if (missingFields.length > 0) {
                result.warnings.push(`Record ${index}: Missing fields: ${missingFields.join(', ')}`);
            }
            
            // Validate age if present
            if (patient.AGE && (isNaN(patient.AGE) || patient.AGE < 0 || patient.AGE > 150)) {
                result.warnings.push(`Record ${index}: Invalid age: ${patient.AGE}`);
            }
        });
        
        this._logDebug(`Validation complete: ${result.recordCount} records, ${result.errors.length} errors, ${result.warnings.length} warnings`);
        
        return result;
    };
    
    /**
     * Format patient data for display in Handsontable
     * @param {Array} patientData - Raw patient data
     * @returns {Array} - Formatted data for table display
     */
    PatientDataService.prototype.formatForTable = function(patientData) {
        if (!Array.isArray(patientData)) {
            this._logDebug('Cannot format invalid patient data for table', 'error');
            return [];
        }

        // Store raw CCL response globally for easy console access (Issue #31 debugging)
        this.lastRawCCLResponse = JSON.parse(JSON.stringify(patientData)); // Deep copy
        window.RAW_CCL_RESPONSE = this.lastRawCCLResponse;
        console.log('📡 RAW CCL RESPONSE: Access via RAW_CCL_RESPONSE in console');

        return patientData.map(patient => {
            const formatted = this.createCaseInsensitiveObject(patient);
            
            // Map camelCase CCL fields to table format
            return {
                PATIENT_NAME: formatted.PATIENT_NAME || formatted.PERSON_NAME || formatted.personName || 'Unknown Patient',
                PERSON_ID: patient.personId || patient.PERSON_ID, // Preserve for navigation
                ENCNTR_ID: patient.encntrId || patient.ENCNTR_ID, // Preserve for navigation
                UNIT: formatted.UNIT || formatted.unit || 'Unknown',
                ROOM_BED: formatted.ROOM_BED || formatted.roomBed || formatted.roombed || '--',
                ALERT_TYPE: this.determineAlertTypeStatus(patient), // Alert type from clinical event data
                timeZero: patient.timeZero || [], // Preserve timeZero array for diagnosis checking (Issue #31)
                SEPSIS_SCREEN_ASSESSMENT: this.determineScreeningStatus(patient), // PowerForm assessment status (backwards compatibility)
                SCREEN_DETAILS: this.determineScreenAssessmentDetails(patient), // Enhanced screen data with criteria for tooltips
                PERFUSION_DETAILS: this.determinePerfusionDetails(patient), // Enhanced perfusion PowerForm data with completion details (v20)
                SEPSIS_PRIORITY: formatted.SEPSIS_PRIORITY || '', // Empty for now - future priority implementation (hidden)
                LAST_SEPSIS_SCREEN: this.determineTimeZeroStatus(patient), // Time Zero based on severe sepsis diagnosis
                TIME_ZERO_DETAILS: this.determineTimeZeroDetails(patient), // Enhanced Time Zero data with source information for tooltips
                SEPSIS_TIMER: this.determineTimerStatus(patient), // Timer calculation based on Time Zero dependency
                SEPSIS_TIMER_SORT: this.determineTimerSortValue(patient), // Numeric value for proper sorting (hidden)
                POWERPLAN_ORDERED: this.determinePowerPlanStatus(patient), // PowerPlan status logic
                powerplans: patient.powerplans || [], // Raw PowerPlan data for tooltip details (Issue #48)
                LACTATE_ORDERED: this.determineLactateOrderedStatus(patient), // Lactate order status logic (backwards compatibility)
                LACTATE_DETAILS: this.determineLactateOrderedDetails(patient), // Enhanced lactate data with timing for tooltips
                LACTATE_RESULT: this.determineLactateResultValue(patient), // Lactate result from initial lactate clinical events
                BLOOD_CULTURES_ORDERED: this.determineBloodCulturesStatus(patient), // Blood culture status logic (backwards compatibility)
                BLOOD_CULTURES_DETAILS: this.determineBloodCulturesDetails(patient), // Enhanced blood culture data with FIRST set timing for tooltips
                ANTIBIOTICS_ORDERED: this.determineAntibioticsOrderedStatus(patient), // Antibiotic order status logic (backwards compatibility)
                ANTIBIOTICS_DETAILS: this.determineAntibioticsOrderedDetails(patient), // Enhanced antibiotic data with existing order info for tooltips
                ALERT_DETAILS: this.determineAlertDetails(patient), // Enhanced alert data with criteria from BLOB for tooltips
                REPEAT_LACTATE_ORDERED: this.determineLactate2Status(patient), // Comprehensive repeat lactate logic (clinical decision support + order tracking)
                SEPSIS_FLUID_ORDERED: this.determineFluidOrderedStatus(patient), // Sepsis fluid order status logic (resuscitation-focused)
                FLUIDS_DETAILS: this.determineFluidOrderedDetails(patient), // Enhanced fluid data with volume amounts for tooltips (Casey's requirement)
                SEPSIS_PRESSORS: (() => {
                    console.log('🔥 ABOUT TO CALL determinePressorsStatus for patient:', patient?.personName);
                    console.log('🔥 Function exists?', typeof this.determinePressorsStatus);
                    const result = this.determinePressorsStatus(patient);
                    console.log('🔥 PRESSORS STATUS RESULT:', result);
                    return result;
                })(), // Pressor medication status (all sources - never in power plan)
                PRESSORS_DETAILS: this.determinePressorsDetails(patient), // Enhanced pressor data with administration times for tooltips (Casey's requirement)
                FLUID_VOLUME_DOCUMENTED: this.determineVolumeDocumentationStatus(patient), // Conditional logic (fluids dependency)
                PERFUSION_ASSESSMENT: this.determinePerfusionAssessmentStatus(patient), // Conditional logic (lactate ≥ 4.0 dependency)
                PATIENT_CLASS: formatted.PATIENT_CLASS || formatted.patientClass || 'Unknown',
                STATUS: formatted.STATUS || 'Unknown',
                ACUITY: formatted.ACUITY || 'Unknown', 
                AGE: this.formatAge(formatted.AGE || formatted.age),
                GENDER: formatted.GENDER || formatted.gender || formatted.sex || 'Unknown',
                ADMISSION_DATE: this.formatDate(formatted.ADMISSION_DATE || formatted.admissionDate || formatted.admission_date)
            };
        });
    };
    
    /**
     * Format age for display
     * @param {*} age - Age value
     * @returns {string} - Formatted age
     */
    PatientDataService.prototype.formatAge = function(age) {
        if (age === null || age === undefined || age === '') {
            return '--';
        }
        
        const numericAge = parseInt(age);
        if (isNaN(numericAge) || numericAge < 0) {
            return '--';
        }
        
        return numericAge.toString();
    };
    
    /**
     * Format date for display
     * @param {*} date - Date value
     * @returns {string} - Formatted date
     */
    PatientDataService.prototype.formatDate = function(date) {
        if (!date) {
            return '--';
        }
        
        try {
            const dateObj = new Date(date);
            if (isNaN(dateObj.getTime())) {
                return date.toString(); // Return as-is if not a valid date
            }
            
            return dateObj.toLocaleDateString();
        } catch (error) {
            this._logDebug(`Error formatting date: ${error.message}`, 'warn');
            return date.toString();
        }
    };
    
    /**
     * Global sepsis phase filtering function - applies to ALL sepsis interventions
     * Excludes non-sepsis phases within sepsis PowerPlans (CSF, CNS, COVID)
     * @param {string} phaseName - Phase name to evaluate
     * @returns {boolean} - True if phase should be included in sepsis tracking
     */
    PatientDataService.prototype.isSepsisSpecificPhase = function(phaseName) {
        if (!phaseName) return false;
        
        const phaseNameLower = phaseName.toLowerCase();
        
        // EXCLUDE patterns (non-sepsis phases within sepsis PowerPlan)
        const excludePatterns = [
            'csf', 'cerebrospinal',           // CSF testing - meningitis workup
            'cns', 'central nervous',         // CNS therapy - brain infection  
            'covid', 'coronavirus', 'pui'     // COVID protocols
        ];
        
        const isExcluded = excludePatterns.some(pattern => 
            phaseNameLower.includes(pattern)
        );
        
        if (isExcluded) {
            this._logDebug(`Phase "${phaseName}" - EXCLUDED from sepsis tracking (non-sepsis pathway)`);
            return false;
        }
        
        // INCLUDE all other phases within sepsis PowerPlans
        // This includes: ED Severe Sepsis, Resuscitation/Antibiotics, Lab Panel, Blood Culture X 2, etc.
        this._logDebug(`Phase "${phaseName}" - INCLUDED in sepsis tracking`);
        return true;
    };
    
    /**
     * Determine PowerPlan status based on patient data
     * Clinical logic: Initiated = "Y", All Planned = "Pend", None = "N"
     * @param {Object} patient - Patient data object
     * @returns {string} - PowerPlan status ("Y", "N", or "Pend")
     */
    PatientDataService.prototype.determinePowerPlanStatus = function(patient) {
        // Check if PowerPlan status is already pre-computed (from mock data)
        if (patient.POWERPLAN_ORDERED) {
            this._logDebug(`Using pre-computed PowerPlan status: ${patient.POWERPLAN_ORDERED}`);
            return patient.POWERPLAN_ORDERED;
        }
        
        // No PowerPlan data at all
        if (!patient.powerplans || !Array.isArray(patient.powerplans) || patient.powerplans.length === 0) {
            this._logDebug('No PowerPlan data found for patient');
            return "N";
        }
        
        // Specific ED Sepsis PowerPlan names from Dr. Crawford
        const validSepsisPlans = [
            "ED Severe Sepsis - ADULT",
            "ED Severe Sepsis - ADULT EKM", 
            "ED Severe Sepsis Resuscitation/Antibiotics - ADULT",
            "ED Severe Sepsis Resuscitation/Antibiotics - ADULT EKM"
        ];
        
        // Check for any of the specified sepsis PowerPlans
        const sepsisPlans = patient.powerplans.filter(pp => 
            validSepsisPlans.includes(pp.ppPowerplanName)
        );
        
        if (sepsisPlans.length === 0) {
            this._logDebug('No matching ED sepsis PowerPlan found');
            return "N"; // No ED sepsis PowerPlan found
        }
        
        // Check phase statuses - looking for "Initiated", "Discontinued", or "Planned" in SEPSIS-SPECIFIC phases only
        for (const plan of sepsisPlans) {
            if (plan.phase && Array.isArray(plan.phase)) {
                // Filter to sepsis-specific phases only (exclude CSF, CNS, COVID)
                const sepsisPhases = plan.phase.filter(phase => 
                    this.isSepsisSpecificPhase(phase.pPhaseName)
                );
                
                this._logDebug(`PowerPlan "${plan.ppPowerplanName}" has ${sepsisPhases.length} sepsis-specific phases out of ${plan.phase.length} total phases`);
                
                const hasInitiatedPhase = sepsisPhases.some(phase => 
                    phase.pStatus === "Initiated"
                );
                
                const hasDiscontinuedPhase = sepsisPhases.some(phase =>
                    phase.pStatus === "Discontinued"
                );
                
                const hasCancelledPhase = sepsisPhases.some(phase =>
                    phase.pStatus === "Cancelled"
                );
                
                if (hasInitiatedPhase) {
                    this._logDebug(`Found initiated sepsis-specific phase in PowerPlan: ${plan.ppPowerplanName}`);
                    return "Y"; // At least one sepsis phase is initiated
                } else if (hasDiscontinuedPhase) {
                    this._logDebug(`Found discontinued sepsis-specific phase in PowerPlan: ${plan.ppPowerplanName} - treating as completed`);
                    return "Y"; // Sepsis PowerPlan was executed and finished (discontinued = completed)
                } else if (hasCancelledPhase) {
                    this._logDebug(`Found cancelled sepsis-specific phase in PowerPlan: ${plan.ppPowerplanName}`);
                    return "N"; // Sepsis PowerPlan was cancelled/stopped incorrectly
                }
            }
        }
        
        // PowerPlan exists but all phases are "Planned" 
        this._logDebug('PowerPlan exists but all phases are planned');
        return "Pend";
    };
    
    /**
     * Determine Lactate Ordered status with timing information for tooltip display
     * Returns enhanced object with status and timing details for Casey's hover requirements
     * @param {Object} patient - Patient data object
     * @returns {Object} - Enhanced lactate object with status and timing data
     */
    PatientDataService.prototype.determineLactateOrderedDetails = function(patient) {
        // Default response structure (based on real Cerner fields)
        const defaultResponse = {
            status: "N",
            orderId: null,
            orderMnemonic: null,
            orderStatus: null,
            catalogCd: null
        };

        // v12 Enhanced: Use new lactate[] array for detailed tooltip information
        if (patient.lactate && Array.isArray(patient.lactate) && patient.lactate.length > 0) {
            this._logDebug(`Processing v12 lactate[] array with ${patient.lactate.length} orders for tooltip details`);

            // Filter out cancelled orders and get first active lactate
            const activeLactates = patient.lactate.filter(order => order.cancelledInd !== 1);

            if (activeLactates.length === 0) {
                this._logDebug('All lactate orders were cancelled');
                return defaultResponse;
            }

            const firstLactate = activeLactates[0];
            this._logDebug(`Using first active lactate for details: ${firstLactate.orderMnemonic}, Status: ${firstLactate.orderStatusDisp}`);

            return {
                status: firstLactate.orderStatusDisp === "Completed" || firstLactate.orderStatusDisp === "Dispatched" ? "Y" :
                       firstLactate.orderStatusDisp === "Ordered" ? "Pend" : "N",
                orderId: firstLactate.orderId,
                orderMnemonic: firstLactate.orderMnemonic,
                orderStatus: firstLactate.orderStatusDisp,
                orderTime: firstLactate.orderDtTmDisp,
                collectionTime: firstLactate.resultDtTmDisp,
                resultValue: firstLactate.resultVal,
                catalogCd: null  // Not needed in v12 structure
            };
        }

        // Fallback to PowerPlan processing for backward compatibility
        this._logDebug('No lactate[] array found - falling back to PowerPlan processing');

        if (!patient.powerplans || !Array.isArray(patient.powerplans) || patient.powerplans.length === 0) {
            this._logDebug('No PowerPlan data found - no lactate orders');
            return defaultResponse;
        }

        // Search sepsis-specific PowerPlan phases for lactate orders
        for (const plan of patient.powerplans) {
            if (plan.phase && Array.isArray(plan.phase)) {
                for (const phase of plan.phase) {
                    // Apply global sepsis phase filtering
                    if (!this.isSepsisSpecificPhase(phase.pPhaseName)) {
                        continue; // Skip non-sepsis phases (CSF, CNS, COVID)
                    }

                    if (phase.orders && Array.isArray(phase.orders)) {
                        // Look for lactate orders by mnemonic
                        const lactateOrder = phase.orders.find(order =>
                            order.oOrderMnemonic === "LA" ||
                            order.oOrderMnemonic === "LACTATE" ||
                            order.oOrderMnemonic.toLowerCase().includes("lactate") ||
                            order.oOrderMnemonic.toLowerCase().includes("lactic")
                        );

                        if (lactateOrder) {
                            this._logDebug(`Found lactate order: ${lactateOrder.oOrderMnemonic} with status: ${lactateOrder.oOrderStatus}`);

                            // Check phase status for clinical context
                            if (phase.pStatus === "Cancelled") {
                                this._logDebug(`Lactate order in cancelled phase: ${phase.pPhaseName}`);
                                return defaultResponse; // Cancelled phase - lactate order not active
                            }

                            // Capture available order information (no timing fields in real Cerner data)
                            const orderDetails = {
                                orderMnemonic: lactateOrder.oOrderMnemonic,
                                orderStatus: lactateOrder.oOrderStatus,
                                orderId: lactateOrder.oOrderId,
                                catalogCd: lactateOrder.oOrderCatalogCd
                            };


                            // Apply completion-focused order status mapping logic
                            switch (lactateOrder.oOrderStatus) {
                                case "Completed":
                                    orderDetails.status = "Y"; // Green checkmark - order truly completed
                                    break;
                                case "Dispatched":
                                case "Ordered":
                                    orderDetails.status = "Pend"; // Yellow pending - order in progress, not completed
                                    break;
                                default:
                                    this._logDebug(`Unknown lactate order status: ${lactateOrder.oOrderStatus}`);
                                    orderDetails.status = "Pend"; // Conservative default for unknown statuses
                            }

                            console.log('🧪 REAL LACTATE ORDER:', lactateOrder);
                            console.log('🧪 LACTATE DETAILS:', orderDetails);
                            return orderDetails;
                        }
                    }
                }
            }
        }

        // No lactate orders found in any PowerPlan phase
        this._logDebug('No lactate orders found in PowerPlan phases');
        return defaultResponse;
    };

    /**
     * Determine Lactate Ordered status based on PowerPlan order data (Legacy function for backwards compatibility)
     * ORDER STATUS MAPPING LOGIC (For Requestor Review):
     * 
     * Cerner Order Status → Healthcare Icon Mapping:
     * - "Dispatched" → "Y" (🟢 Green filled circle ✓) - Lab order sent to department
     * - "Completed" → "Y" (🟢 Green filled circle ✓) - Order fulfilled/resulted
     * - "Ordered" → "Pend" (🟡 Yellow half-filled ◐) - Order placed but not processed
     * - Not found → "N" (⚪ Gray empty circle ○) - Order not placed
     * 
     * Real Data Examples (Encounter 114259401):
     * - LA (Lactate): "Dispatched" → "Y" → Green circle with checkmark
     * - C Blood (Cultures): "Dispatched" → "Y" → Green circle with checkmark  
     * - Peripheral IV: "Ordered" → "Pend" → Yellow half-filled circle
     * 
     * @param {Object} patient - Patient data object with PowerPlan structure
     * @returns {string} - Lactate order status ("Y", "N", or "Pend")
     */
    PatientDataService.prototype.determineLactateOrderedStatus = function(patient) {
        // Check if Lactate status is already pre-computed (from mock data)
        if (patient.LACTATE_ORDERED) {
            this._logDebug(`Using pre-computed Lactate status: ${patient.LACTATE_ORDERED}`);
            return patient.LACTATE_ORDERED;
        }

        // v12 Enhanced: Use new lactate[] array from all sources (ED Lab Panel + PowerPlan + ad-hoc)
        if (patient.lactate && Array.isArray(patient.lactate) && patient.lactate.length > 0) {
            this._logDebug(`Found ${patient.lactate.length} lactate orders from enhanced v12 detection`);

            // Filter out cancelled orders for status determination
            const activeLactates = patient.lactate.filter(order => order.cancelledInd !== 1);

            if (activeLactates.length === 0) {
                this._logDebug('All lactate orders were cancelled');
                return "N";
            }

            // Get first non-cancelled lactate order (chronologically)
            const firstLactate = activeLactates[0];
            this._logDebug(`First active lactate: ${firstLactate.orderMnemonic}, Status: ${firstLactate.orderStatusDisp}`);

            // Map Cerner order status to our display logic
            const orderStatus = firstLactate.orderStatusDisp;
            if (orderStatus === "Completed" || orderStatus === "Dispatched") {
                return "Y"; // Completed or in progress
            } else if (orderStatus === "Ordered") {
                return "Pend"; // Ordered but not yet processed
            } else {
                return "N"; // Other statuses (discontinued, etc.)
            }
        }

        // Fallback to old PowerPlan logic for backward compatibility
        if (!patient.powerplans || !Array.isArray(patient.powerplans) || patient.powerplans.length === 0) {
            this._logDebug('No lactate[] array and no PowerPlan data found');
            return "N";
        }

        // Legacy PowerPlan search for lactate orders (backward compatibility)
        for (const plan of patient.powerplans) {
            if (plan.phase && Array.isArray(plan.phase)) {
                for (const phase of plan.phase) {
                    // Apply global sepsis phase filtering
                    if (!this.isSepsisSpecificPhase(phase.pPhaseName)) {
                        continue; // Skip non-sepsis phases (CSF, CNS, COVID)
                    }
                    
                    if (phase.orders && Array.isArray(phase.orders)) {
                        // Look for lactate orders by mnemonic
                        const lactateOrder = phase.orders.find(order => 
                            order.oOrderMnemonic === "LA" || 
                            order.oOrderMnemonic === "LACTATE" ||
                            order.oOrderMnemonic.toLowerCase().includes("lactate") ||
                            order.oOrderMnemonic.toLowerCase().includes("lactic")
                        );
                        
                        if (lactateOrder) {
                            this._logDebug(`Found lactate order: ${lactateOrder.oOrderMnemonic} with status: ${lactateOrder.oOrderStatus}`);
                            
                            // Check phase status for clinical context
                            if (phase.pStatus === "Cancelled") {
                                this._logDebug(`Lactate order in cancelled phase: ${phase.pPhaseName}`);
                                return "N"; // Cancelled phase - lactate order not active
                            }
                            
                            // Apply completion-focused order status mapping logic
                            switch (lactateOrder.oOrderStatus) {
                                case "Completed":
                                    return "Y"; // Green checkmark - order truly completed
                                case "Dispatched":
                                case "Ordered":
                                    return "Pend"; // Yellow pending - order in progress, not completed
                                default:
                                    this._logDebug(`Unknown lactate order status: ${lactateOrder.oOrderStatus}`);
                                    return "Pend"; // Conservative default for unknown statuses
                            }
                        }
                    }
                }
            }
        }
        
        // No lactate orders found in any PowerPlan phase
        this._logDebug('No lactate orders found in PowerPlan phases');
        return "N";
    };
    
    /**
     * Determine Blood Cultures Ordered status based on PowerPlan order data
     * NURSING-FOCUSED ORDER STATUS MAPPING LOGIC (For Requestor Review):
     * 
     * Blood Culture Workflow: Order → Dispatch → Collection → Lab Processing → Results
     * Nursing Decision Point: "Has blood been collected?" (Can we give antibiotics?)
     * 
     * Cerner Order Status → Healthcare Icon Mapping:
     * - "Dispatched" → "Pend" (🟡 Yellow half-filled ◐) - Order sent to lab, awaiting collection
     * - "Collected" → "Y" (🟢 Green filled circle ✓) - Blood samples obtained, safe for antibiotics
     * - "In Lab" → "Y" (🟢 Green filled circle ✓) - Samples collected and processing
     * - "Completed" → "Y" (🟢 Green filled circle ✓) - Results available  
     * - "Processed" → "Y" (🟢 Green filled circle ✓) - Lab processing complete
     * - Not found → "N" (⚪ Gray empty circle ○) - Blood cultures not ordered
     * 
     * DIFFERENT FROM LACTATE MAPPING:
     * - Lactate: "Dispatched" → "Y" (lab processing focus)
     * - Blood Cultures: "Dispatched" → "Pend" (collection focus for nursing workflow)
     * 
     * Real Data Examples (Encounter 114259401):
     * - C Blood orders: "Dispatched" → "Pend" → Yellow half-filled (awaiting collection)
     * - Future: "Collected" → "Y" → Green circle (safe for antibiotics)
     * 
     * @param {Object} patient - Patient data object with PowerPlan structure
     * @returns {string} - Blood culture order status ("Y", "N", or "Pend")
     */
    /**
     * Determine Blood Culture details using current PowerPlan data
     * AWAITING: Real Cerner JSON response to understand actual two-set structure
     * Currently shows available order information until real data structure is provided
     * @param {Object} patient - Patient data object
     * @returns {Object} - Blood culture object with currently available data
     */
    PatientDataService.prototype.determineBloodCulturesDetails = function(patient) {
        // Default response structure (based on real Cerner fields)
        const defaultResponse = {
            status: "N",
            firstSetOrderId: null,
            firstSetStatus: null,
            firstSetCatalogCd: null,
            phase: null,
            totalSets: 0,
            overallStatus: "Not Ordered",
            bloodCultures: []
        };

        // v18 Enhanced: Use new bloodCultures[] array with complete action timeline
        // Check both camelCase and lowercase (CCL mode 4 conversion inconsistency)
        const bloodCulturesArray = patient.bloodCultures || patient.bloodcultures;

        if (bloodCulturesArray && Array.isArray(bloodCulturesArray) && bloodCulturesArray.length > 0) {
            this._logDebug(`Processing v18 bloodCultures[] array with ${bloodCulturesArray.length} sets for tooltip details`);

            // Process all blood cultures with their action timelines
            const culturesWithTiming = bloodCulturesArray.map(bc => {
                this._logDebug(`Processing Set ${bc.setNumber}: ${bc.orderMnemonic} (ID: ${bc.orderId})`);

                // Extract key action times from actions[] sub-array
                let orderedTime = bc.orderDtTmDisp;  // Order time from order itself
                let dispatchedTime = null;
                let collectedTime = null;
                let inLabTime = null;
                let prelimTime = null;
                let completedTime = null;

                if (bc.actions && Array.isArray(bc.actions)) {
                    bc.actions.forEach(action => {
                        // Match by dept_status_cd (from CERT test results)
                        if (action.deptStatusCd === 9315) {  // LABDISPATCH
                            dispatchedTime = action.actionDtTmDisp;
                        } else if (action.deptStatusCd === 9311) {  // LABCOLLECTED - KEY for antibiotics!
                            collectedTime = action.actionDtTmDisp;
                            this._logDebug(`  Set ${bc.setNumber} COLLECTED at: ${collectedTime}`);
                        } else if (action.deptStatusCd === 9322) {  // LABINLAB
                            inLabTime = action.actionDtTmDisp;
                        } else if (action.deptStatusCd === 9329) {  // LABPRELIM
                            prelimTime = action.actionDtTmDisp;
                        } else if (action.deptStatusCd === 9312) {  // COMPLETED
                            completedTime = action.actionDtTmDisp;
                        }
                    });
                }

                return {
                    setNumber: bc.setNumber,
                    orderMnemonic: bc.orderMnemonic,
                    orderId: bc.orderId,
                    orderedTime: orderedTime,
                    dispatchedTime: dispatchedTime,
                    collectedTime: collectedTime,  // Casey's key requirement
                    inLabTime: inLabTime,
                    prelimTime: prelimTime,
                    completedTime: completedTime,
                    currentStatus: bc.currentDeptStatusDisp,
                    totalActions: bc.totalActions
                };
            });

            // Determine overall status (at least one collected = safe for antibiotics)
            const anyCollected = culturesWithTiming.some(bc => bc.collectedTime !== null);
            const allOrdered = culturesWithTiming.every(bc => bc.orderedTime !== null);

            return {
                status: anyCollected ? "Y" : (allOrdered ? "Pend" : "N"),
                bloodCultures: culturesWithTiming,
                totalSets: culturesWithTiming.length,
                overallStatus: anyCollected ? "Collected" : (allOrdered ? "Pending Collection" : "Not Ordered"),
                firstSetOrderId: culturesWithTiming[0]?.orderId,
                firstSetStatus: culturesWithTiming[0]?.currentStatus
            };
        }

        // Fallback to PowerPlan processing for backward compatibility
        this._logDebug('No bloodCultures[] array found - falling back to PowerPlan processing');

        if (!patient.powerplans || !Array.isArray(patient.powerplans) || patient.powerplans.length === 0) {
            this._logDebug('No PowerPlan data found - no blood culture orders');
            return defaultResponse;
        }

        // Search sepsis-specific PowerPlan phases for blood culture orders
        for (const plan of patient.powerplans) {
            if (plan.phase && Array.isArray(plan.phase)) {
                for (const phase of plan.phase) {
                    // Apply global sepsis phase filtering
                    if (!this.isSepsisSpecificPhase(phase.pPhaseName)) {
                        continue; // Skip non-sepsis phases
                    }

                    if (phase.pStatus === "Cancelled") {
                        this._logDebug(`Blood cultures in cancelled phase: ${phase.pPhaseName}`);
                        continue; // Skip cancelled phases
                    }

                    if (phase.orders && Array.isArray(phase.orders)) {
                        // Look for blood culture orders (existing logic)
                        const bloodCultureOrders = phase.orders.filter(order =>
                            order.oOrderMnemonic === "C Blood" ||
                            order.oOrderMnemonic === "Blood Culture" ||
                            order.oOrderMnemonic.toLowerCase().includes("blood culture") ||
                            order.oOrderMnemonic.toLowerCase().includes("culture")
                        );

                        if (bloodCultureOrders.length > 0) {
                            this._logDebug(`Found ${bloodCultureOrders.length} blood culture orders - finding first collected/completed set per Casey's requirement`);

                            // Look for the FIRST set that is collected/completed (most clinically relevant)
                            const collectedSets = bloodCultureOrders.filter(order =>
                                ["Collected", "In Lab", "Completed", "Processed"].includes(order.oOrderStatus)
                            ).sort((a, b) => a.oOrderId - b.oOrderId); // Sort by order ID

                            let firstSet;
                            if (collectedSets.length > 0) {
                                // Use first collected set (most clinically relevant)
                                firstSet = collectedSets[0];
                                this._logDebug(`FIRST COLLECTED blood culture set: ${firstSet.oOrderMnemonic} (ID: ${firstSet.oOrderId}) - Status: ${firstSet.oOrderStatus}`);
                            } else {
                                // If none collected, use first ordered set as fallback
                                bloodCultureOrders.sort((a, b) => a.oOrderId - b.oOrderId);
                                firstSet = bloodCultureOrders[0];
                                this._logDebug(`FIRST ORDERED blood culture set (none collected yet): ${firstSet.oOrderMnemonic} (ID: ${firstSet.oOrderId}) - Status: ${firstSet.oOrderStatus}`);
                            }

                            // Capture available blood culture information (real Cerner structure)
                            const firstSetDetails = {
                                phase: phase.pPhaseName,
                                firstSetStatus: firstSet.oOrderStatus,
                                firstSetOrderId: firstSet.oOrderId, // Critical for differentiating between the two sets
                                firstSetCatalogCd: firstSet.oOrderCatalogCd,
                                totalSets: bloodCultureOrders.length // Show how many blood culture sets were ordered
                            };

                            // Determine status using existing nursing-focused logic
                            const isCollected = ["Collected", "In Lab", "Completed", "Processed"].includes(firstSet.oOrderStatus);
                            const isOrdered = ["Dispatched", "Ordered"].includes(firstSet.oOrderStatus);

                            if (isCollected) {
                                firstSetDetails.status = "Y";
                                firstSetDetails.overallStatus = "Collected";
                            } else if (isOrdered) {
                                firstSetDetails.status = "Pend";
                                firstSetDetails.overallStatus = "Pending Collection";
                            } else {
                                firstSetDetails.status = "N";
                                firstSetDetails.overallStatus = "Not Ordered";
                            }

                            return firstSetDetails;
                        }
                    }
                }
            }
        }

        // No blood culture orders found
        this._logDebug('No blood culture orders found in PowerPlan phases');
        return defaultResponse;
    };

    PatientDataService.prototype.determineBloodCulturesStatus = function(patient) {
        // v18 Enhanced: ALWAYS check new bloodcultures[] array first (Issue #17/19 fix)
        // Don't use pre-computed value - calculate from actual dept statuses
        const bloodCulturesArray = patient.bloodCultures || patient.bloodcultures;
        if (bloodCulturesArray && Array.isArray(bloodCulturesArray) && bloodCulturesArray.length > 0) {
            this._logDebug(`Checking v18 bloodcultures[] array with ${bloodCulturesArray.length} sets`);

            // Check if ANY blood culture set is collected or better
            const anyCollected = bloodCulturesArray.some(bc => {
                const status = bc.currentDeptStatusDisp || bc.currentOrderStatusDisp || "";
                const isCollected = ["Collected", "In-Lab", "In Lab", "Preliminary", "Completed"].includes(status);
                this._logDebug(`  Set ${bc.setNumber}: ${status} - Collected: ${isCollected}`);
                return isCollected;
            });

            if (anyCollected) {
                this._logDebug('At least one blood culture collected → Y');
                return "Y";
            }

            // Check if dispatched/ordered
            const anyOrdered = bloodCulturesArray.some(bc => {
                const status = bc.currentDeptStatusDisp || bc.currentOrderStatusDisp || "";
                return ["Dispatched", "Ordered"].includes(status);
            });

            if (anyOrdered) {
                return "Pend";
            }
        }

        // Fallback: Check PowerPlan phase.orders (legacy logic)
        if (!patient.powerplans || !Array.isArray(patient.powerplans) || patient.powerplans.length === 0) {
            this._logDebug('No PowerPlan data found - no blood culture orders');
            return "N";
        }
        
        // Search sepsis-specific PowerPlan phases for blood culture orders
        for (const plan of patient.powerplans) {
            if (plan.phase && Array.isArray(plan.phase)) {
                for (const phase of plan.phase) {
                    // Apply global sepsis phase filtering
                    if (!this.isSepsisSpecificPhase(phase.pPhaseName)) {
                        continue; // Skip non-sepsis phases (CSF, CNS, COVID)
                    }
                    
                    if (phase.orders && Array.isArray(phase.orders)) {
                        // Look for ALL blood culture orders by mnemonic (usually 2 cultures)
                        const bloodCultureOrders = phase.orders.filter(order => 
                            order.oOrderMnemonic === "C Blood" || 
                            order.oOrderMnemonic === "Blood Culture" ||
                            order.oOrderMnemonic.toLowerCase().includes("blood culture") ||
                            order.oOrderMnemonic.toLowerCase().includes("culture")
                        );
                        
                        if (bloodCultureOrders.length > 0) {
                            this._logDebug(`Found ${bloodCultureOrders.length} blood culture orders`);
                            
                            // Check phase status - for blood cultures, need actual collection status
                            if (phase.pStatus === "Cancelled") {
                                this._logDebug(`Blood cultures in cancelled phase: ${phase.pPhaseName}`);
                                return "N"; // Cancelled phase - blood cultures not active
                            }
                            
                            // For discontinued phases, still check individual order statuses
                            // because some orders might have been collected before discontinuation
                            
                            // REQUESTOR CLARIFICATION: "At least one needs to be collected"
                            // Check if ANY blood culture is collected (safe for antibiotics)
                            const anyCollected = bloodCultureOrders.some(order => {
                                const isCollected = ["Collected", "In Lab", "In-Lab", "Completed", "Processed"].includes(order.oOrderStatus);
                                this._logDebug(`Blood culture ${order.oOrderId}: ${order.oOrderStatus} - Collected: ${isCollected}`);
                                return isCollected;
                            });
                            
                            // Check if ANY blood culture is ordered/dispatched
                            const anyOrdered = bloodCultureOrders.some(order => 
                                ["Dispatched", "Ordered"].includes(order.oOrderStatus)
                            );
                            
                            if (anyCollected) {
                                return "Y"; // At least one culture collected - safe for antibiotics
                            } else if (anyOrdered) {
                                return "Pend"; // Cultures ordered but none collected yet
                            } else {
                                this._logDebug(`Unknown blood culture statuses found`);
                                return "Pend"; // Conservative default
                            }
                        }
                    }
                }
            }
        }
        
        // No blood culture orders found in any PowerPlan phase
        this._logDebug('No blood culture orders found in PowerPlan phases');
        return "N";
    };
    
    /**
     * Determine Antibiotics Ordered status based on PowerPlan order data
     * ORDER-FOCUSED CLINICAL LOGIC (For Requestor Review):
     * 
     * Antibiotic Workflow: Order → Pharmacy → Administration
     * Clinical Decision Point: "Were sepsis antibiotics ordered?" (Intervention initiated)
     * 
     * Cerner Order Status → Healthcare Icon Mapping:
     * - "Ordered" → "Y" (🟢 Green filled circle ✓) - Antibiotic intervention initiated
     * - "Dispatched" → "Y" (🟢 Green filled circle ✓) - Antibiotic sent to pharmacy
     * - "Completed" → "Y" (🟢 Green filled circle ✓) - Antibiotic administered
     * - "Cancelled" phase → "N" (⚪ Gray empty circle ○) - Antibiotic orders not active
     * - Not found → "N" (⚪ Gray empty circle ○) - No sepsis antibiotics ordered
     * 
     * DIFFERENT FROM BLOOD CULTURES:
     * - Blood Cultures: Focus on collection (physical blood obtained)
     * - Antibiotics: Focus on ordering (intervention initiated)
     * 
     * SEPSIS-SPECIFIC FILTERING:
     * - INCLUDE: Antibiotics in sepsis phases (ED Severe Sepsis, Resuscitation/Antibiotics, etc.)
     * - EXCLUDE: CNS antibiotics (ED CNS Empiric Drug Therapy), CSF antibiotics, COVID antibiotics
     * 
     * Real Data Examples (From Console):
     * - ZZTEST, SEPSISONE: piperacillin/tazobactam + linezolid in "ED Severe Sepsis - ADULT EKM" → "Y"
     * - ZZTEST, ZZSEPSISTWO: vancomycin in CNS phase (excluded) + piperacillin in sepsis phase (included) → "Y"
     * 
     * @param {Object} patient - Patient data object with PowerPlan structure
     * @returns {string} - Antibiotic order status ("Y", "N", or "Pend")
     */
    /**
     * Determine Antibiotic order details using only existing PowerPlan data for tooltip display
     * Returns enhanced object with available antibiotic information for tooltips
     * Uses ONLY current data - no mock administration times until available from Cerner
     * @param {Object} patient - Patient data object
     * @returns {Object} - Enhanced antibiotic object with existing order data
     */
    PatientDataService.prototype.determineAntibioticsOrderedDetails = function(patient) {
        // Default response structure
        const defaultResponse = {
            status: "N",
            antibiotics: [],
            phase: null,
            overallStatus: "Not Ordered"
        };

        // v13 Enhanced: Use new antibiotics[] array for comprehensive tooltip data (Casey's requirement)
        if (patient.antibiotics && Array.isArray(patient.antibiotics) && patient.antibiotics.length > 0) {
            this._logDebug(`Processing v13 antibiotics[] array with ${patient.antibiotics.length} orders for tooltip details`);

            // Find administered antibiotics for priority display
            const administeredAntibiotics = patient.antibiotics.filter(antibiotic =>
                antibiotic.firstAdminDtTmDisp &&
                antibiotic.firstAdminDtTmDisp !== "" &&
                !antibiotic.firstAdminDtTmDisp.includes("1900-01-01")
            );

            // Process antibiotics for tooltip display
            const antibioticsDetails = patient.antibiotics.map(antibiotic => ({
                orderMnemonic: antibiotic.orderMnemonic,
                primaryMnemonic: antibiotic.primaryMnemonic || antibiotic.orderMnemonic,  // v21: Standardized name
                orderId: antibiotic.orderId || 0,  // v21: For debugging (catalogCd in JSON only, not displayed)
                powerplanPhase: antibiotic.powerplanPhase,
                orderStatus: antibiotic.orderStatusDisp,
                administered: antibiotic.firstAdminDtTmDisp && !antibiotic.firstAdminDtTmDisp.includes("1900-01-01"),
                firstAdminTime: antibiotic.firstAdminDtTmDisp || "Not administered",
                totalDoses: antibiotic.totalAdministrations || 0
            }));

            if (administeredAntibiotics.length > 0) {
                const firstAdmin = administeredAntibiotics[0];
                return {
                    status: "Y",
                    antibiotics: antibioticsDetails,
                    phase: firstAdmin.powerplanPhase,
                    overallStatus: "Administered",
                    firstAdministered: {
                        orderMnemonic: firstAdmin.orderMnemonic,
                        adminTime: firstAdmin.firstAdminDtTmDisp,
                        totalDoses: firstAdmin.totalAdministrations
                    },
                    totalOrders: patient.antibiotics.length,
                    administeredCount: administeredAntibiotics.length
                };
            } else {
                // All antibiotics ordered but none administered yet
                return {
                    status: "Pend",
                    antibiotics: antibioticsDetails,
                    phase: patient.antibiotics[0].powerplanPhase,
                    overallStatus: "Ordered - Pending Administration",
                    totalOrders: patient.antibiotics.length,
                    administeredCount: 0
                };
            }
        }

        // Fallback to old PowerPlan logic for backward compatibility
        if (!patient.powerplans || !Array.isArray(patient.powerplans) || patient.powerplans.length === 0) {
            this._logDebug('No antibiotics[] array and no PowerPlan data found');
            return defaultResponse;
        }

        // Legacy PowerPlan search for antibiotic orders (backward compatibility)
        const antibioticPatterns = [
            "piperacillin", "tazobactam",           // Zosyn - primary broad-spectrum
            "vancomycin",                           // Vanc - MRSA coverage
            "linezolid",                           // Linezolid - MRSA alternative
            "levofloxacin", "levoFLOXacin",        // Levaquin - atypical coverage
            "cefepime",                            // Cefepime - penicillin allergy alternative
            "metronidazole", "metroNIDAZOLE"       // Flagyl - anaerobic coverage
        ];

        let foundAntibiotics = [];
        let foundPhase = null;

        for (const plan of patient.powerplans) {
            if (plan.phase && Array.isArray(plan.phase)) {
                for (const phase of plan.phase) {
                    // Apply global sepsis phase filtering (using existing function)
                    if (!this.isSepsisSpecificPhase(phase.pPhaseName)) {
                        continue; // Skip non-sepsis phases (CSF, CNS, COVID)
                    }

                    // Check phase status for clinical context
                    if (phase.pStatus === "Cancelled") {
                        this._logDebug(`Antibiotic orders in cancelled sepsis phase: ${phase.pPhaseName}`);
                        continue; // Skip cancelled phases
                    }

                    if (phase.orders && Array.isArray(phase.orders)) {
                        // Look for ANY antibiotic orders in sepsis-specific phases (using existing logic)
                        const antibioticOrders = phase.orders.filter(order => {
                            const orderMnemonic = order.oOrderMnemonic.toLowerCase();
                            return antibioticPatterns.some(pattern =>
                                orderMnemonic.includes(pattern.toLowerCase())
                            );
                        });

                        if (antibioticOrders.length > 0) {
                            this._logDebug(`Found ${antibioticOrders.length} sepsis antibiotic orders in phase: ${phase.pPhaseName}`);
                            foundPhase = phase.pPhaseName;

                            // Capture existing order information (no new mock data)
                            antibioticOrders.forEach(order => {
                                foundAntibiotics.push({
                                    name: order.oOrderMnemonic,
                                    status: order.oOrderStatus
                                });
                                this._logDebug(`  Antibiotic: "${order.oOrderMnemonic}" - Status: "${order.oOrderStatus}"`);
                            });
                        }
                    }
                }
            }
        }

        // Determine overall status using existing logic
        const anyAntibioticOrdered = foundAntibiotics.some(ab =>
            ["Ordered", "Dispatched", "Completed"].includes(ab.status)
        );

        const result = {
            status: anyAntibioticOrdered ? "Y" : "N",
            antibiotics: foundAntibiotics,
            phase: foundPhase,
            overallStatus: anyAntibioticOrdered ? "Ordered" : "Not Ordered"
        };

        return result;
    };

    PatientDataService.prototype.determineAntibioticsOrderedStatus = function(patient) {
        // Check if Antibiotics status is already pre-computed (from mock data)
        if (patient.ANTIBIOTICS_ORDERED) {
            this._logDebug(`Using pre-computed Antibiotics status: ${patient.ANTIBIOTICS_ORDERED}`);
            return patient.ANTIBIOTICS_ORDERED;
        }

        // v13 Enhanced: Use new antibiotics[] array for administration-based status (Casey's requirement)
        if (patient.antibiotics && Array.isArray(patient.antibiotics) && patient.antibiotics.length > 0) {
            this._logDebug(`Found ${patient.antibiotics.length} antibiotics from v13 PowerPlan processing`);

            // Check if ANY antibiotic has been administered (Casey's clinical requirement)
            const administeredAntibiotics = patient.antibiotics.filter(antibiotic =>
                antibiotic.firstAdminDtTmDisp &&
                antibiotic.firstAdminDtTmDisp !== "" &&
                antibiotic.firstAdminDtTmDisp !== "1900-01-01T05:00:00.000" &&
                !antibiotic.firstAdminDtTmDisp.includes("1900-01-01")
            );

            if (administeredAntibiotics.length > 0) {
                const firstAdmin = administeredAntibiotics[0];
                this._logDebug(`SEP-1 COMPLIANCE: Antibiotic administered - ${firstAdmin.orderMnemonic} at ${firstAdmin.firstAdminDtTmDisp}`);
                return "Y"; // Green checkmark - SEP-1 compliance met
            } else {
                this._logDebug(`Antibiotics ordered but none administered yet - ${patient.antibiotics.length} orders pending`);
                return "Pend"; // Yellow pending - ordered but not administered
            }
        }

        // Fallback to old PowerPlan logic for backward compatibility
        if (!patient.powerplans || !Array.isArray(patient.powerplans) || patient.powerplans.length === 0) {
            this._logDebug('No antibiotics[] array and no PowerPlan data found');
            return "N";
        }

        // Legacy PowerPlan search for antibiotic orders (backward compatibility)
        const antibioticPatterns = [
            "piperacillin", "tazobactam",           // Zosyn - primary broad-spectrum
            "vancomycin",                           // Vanc - MRSA coverage
            "linezolid",                           // Linezolid - MRSA alternative
            "levofloxacin", "levoFLOXacin",        // Levaquin - atypical coverage
            "cefepime",                            // Cefepime - penicillin allergy alternative
            "metronidazole", "metroNIDAZOLE"       // Flagyl - anaerobic coverage
        ];

        // Search sepsis-specific PowerPlan phases for antibiotic orders
        for (const plan of patient.powerplans) {
            if (plan.phase && Array.isArray(plan.phase)) {
                for (const phase of plan.phase) {
                    // Apply global sepsis phase filtering
                    if (!this.isSepsisSpecificPhase(phase.pPhaseName)) {
                        continue; // Skip non-sepsis phases (CSF, CNS, COVID)
                    }
                    
                    // Check phase status for clinical context
                    if (phase.pStatus === "Cancelled") {
                        this._logDebug(`Antibiotic orders in cancelled sepsis phase: ${phase.pPhaseName}`);
                        continue; // Skip cancelled phases
                    }
                    
                    if (phase.orders && Array.isArray(phase.orders)) {
                        // Look for ANY antibiotic orders in sepsis-specific phases
                        const antibioticOrders = phase.orders.filter(order => {
                            const orderMnemonic = order.oOrderMnemonic.toLowerCase();
                            return antibioticPatterns.some(pattern => 
                                orderMnemonic.includes(pattern.toLowerCase())
                            );
                        });
                        
                        if (antibioticOrders.length > 0) {
                            this._logDebug(`Found ${antibioticOrders.length} sepsis antibiotic orders in phase: ${phase.pPhaseName}`);
                            antibioticOrders.forEach(order => {
                                this._logDebug(`  Sepsis antibiotic: "${order.oOrderMnemonic}" - Status: "${order.oOrderStatus}"`);
                            });
                            
                            // Check if ANY antibiotic is ordered/dispatched/completed
                            const anyAntibioticOrdered = antibioticOrders.some(order => 
                                ["Ordered", "Dispatched", "Completed"].includes(order.oOrderStatus)
                            );
                            
                            if (anyAntibioticOrdered) {
                                return "Y"; // At least one sepsis antibiotic ordered - intervention initiated
                            }
                        }
                    }
                }
            }
        }
        
        // No sepsis-specific antibiotic orders found
        this._logDebug('No sepsis-specific antibiotic orders found in PowerPlan phases');
        return "N";
    };
    
    /**
     * Determine Sepsis Fluids Ordered status based on PowerPlan order data  
     * FLUID RESUSCITATION-FOCUSED CLINICAL LOGIC (For Requestor Review):
     * 
     * Sepsis Fluid Workflow: Order → Pharmacy → Administration (SEP-1 Bundle)
     * Clinical Decision Point: "Were sepsis fluid resuscitation orders placed?" (30 mL/kg requirement)
     * 
     * Cerner Order Status → Healthcare Icon Mapping:
     * - "Ordered" → "Y" (🟢 Green filled circle ✓) - Sepsis fluid resuscitation ordered
     * - "Dispatched" → "Y" (🟢 Green filled circle ✓) - Fluid sent to unit
     * - "Completed" → "Y" (🟢 Green filled circle ✓) - Fluid administered
     * - "Cancelled" phase → "N" (⚪ Gray empty circle ○) - Fluid orders not active
     * - Not found → "N" (⚪ Gray empty circle ○) - No sepsis fluids ordered
     * 
     * SEPSIS-SPECIFIC FILTERING:
     * - INCLUDE: Fluids in sepsis phases (ED Severe Sepsis, Resuscitation/Antibiotics, etc.)
     * - EXCLUDE: Fluids in CNS phases, CSF phases, COVID phases
     * 
     * SEP-1 BUNDLE FOCUS:
     * - Tracks sepsis fluid resuscitation (30 mL/kg crystalloid requirement)
     * - Order-focused logic (intervention initiated when ordered)
     * - Different from blood cultures (no collection requirement)
     * 
     * Real Data Examples (From Console):
     * - "Sodium Chloride 0.9% intravenous solution" in sepsis phases → "Y"
     * - "Sodium Chloride 0.9% 1,000 mL" in sepsis phases → "Y"
     * 
     * @param {Object} patient - Patient data object with PowerPlan structure
     * @returns {string} - Sepsis fluid order status ("Y", "N", or "Pend")
     */
    PatientDataService.prototype.determineFluidOrderedStatus = function(patient) {
        // Check if Fluid status is already pre-computed (from mock data)
        if (patient.SEPSIS_FLUID_ORDERED) {
            this._logDebug(`Using pre-computed Sepsis Fluid status: ${patient.SEPSIS_FLUID_ORDERED}`);
            return patient.SEPSIS_FLUID_ORDERED;
        }

        // v14 Enhanced: Use new fluids[] array for administration-based status (Casey's requirement)
        if (patient.fluids && Array.isArray(patient.fluids) && patient.fluids.length > 0) {
            this._logDebug(`Found ${patient.fluids.length} fluids from v14 all-source detection`);

            // v17 Enhancement: Filter out multi-ingredient IV drips (GitHub Issue #6)
            const pureFluidOrders = patient.fluids.filter(fluid => fluid.multiIngredientInd === 0);
            const excludedFluids = patient.fluids.filter(fluid => fluid.multiIngredientInd === 1);

            if (excludedFluids.length > 0) {
                this._logDebug(`v17 Multi-ingredient exclusion: ${excludedFluids.length} medication-mixed fluids excluded`);
                excludedFluids.forEach(fluid => {
                    this._logDebug(`  EXCLUDED: "${fluid.orderMnemonic}" (multiIngredientInd=1)`);
                });
            }

            this._logDebug(`v17 Pure crystalloid fluids: ${pureFluidOrders.length} (after multi-ingredient exclusion)`);

            // Check if ANY pure crystalloid fluid has been administered (Casey's clinical requirement)
            const administeredFluids = pureFluidOrders.filter(fluid =>
                fluid.firstAdminDtTmDisp &&
                fluid.firstAdminDtTmDisp !== "" &&
                !fluid.firstAdminDtTmDisp.includes("1900-01-01")
            );

            if (administeredFluids.length > 0) {
                const totalVolume = pureFluidOrders.reduce((sum, fluid) => sum + (fluid.totalVolumeMl || 0), 0);
                this._logDebug(`SEP-1 COMPLIANCE: Pure crystalloid fluids administered - ${administeredFluids.length} orders, Total: ${totalVolume} mL`);
                return "Y"; // Green checkmark - SEP-1 compliance met
            } else if (pureFluidOrders.length > 0) {
                this._logDebug(`Pure crystalloid fluids ordered but none administered yet - ${pureFluidOrders.length} orders pending`);
                return "Pend"; // Yellow pending - ordered but not administered
            } else {
                this._logDebug(`All fluids were multi-ingredient (excluded) - no pure crystalloids found`);
                return "N"; // No pure crystalloid fluids ordered
            }
        }

        // Fallback to old PowerPlan logic for backward compatibility
        if (!patient.powerplans || !Array.isArray(patient.powerplans) || patient.powerplans.length === 0) {
            this._logDebug('No fluids[] array and no PowerPlan data found');
            return "N";
        }

        // Legacy PowerPlan search for fluid orders (backward compatibility)
        const fluidPatterns = [
            "sodium chloride", "normal saline", "ns",       // Primary saline solutions
            "0.9%", "saline",                               // Concentration indicators
            "lactated ringer", "lr", "ringer",             // Alternative crystalloids
            "crystalloid", "fluid resuscitation",          // General sepsis fluid terms
            "bolus", "ml/kg", "mL/kg"                       // Resuscitation dosing indicators
        ];

        // Search sepsis-specific PowerPlan phases for fluid orders
        for (const plan of patient.powerplans) {
            if (plan.phase && Array.isArray(plan.phase)) {
                for (const phase of plan.phase) {
                    // Apply global sepsis phase filtering
                    if (!this.isSepsisSpecificPhase(phase.pPhaseName)) {
                        continue; // Skip non-sepsis phases (CSF, CNS, COVID)
                    }
                    
                    // Check phase status for clinical context
                    if (phase.pStatus === "Cancelled") {
                        this._logDebug(`Sepsis fluid orders in cancelled phase: ${phase.pPhaseName}`);
                        continue; // Skip cancelled phases
                    }
                    
                    if (phase.orders && Array.isArray(phase.orders)) {
                        // Look for ANY sepsis fluid orders in sepsis-specific phases
                        const fluidOrders = phase.orders.filter(order => {
                            const orderMnemonic = order.oOrderMnemonic.toLowerCase();
                            return fluidPatterns.some(pattern => 
                                orderMnemonic.includes(pattern.toLowerCase())
                            );
                        });
                        
                        if (fluidOrders.length > 0) {
                            this._logDebug(`Found ${fluidOrders.length} sepsis fluid orders in phase: ${phase.pPhaseName}`);
                            fluidOrders.forEach(order => {
                                this._logDebug(`  Sepsis fluid: "${order.oOrderMnemonic}" - Status: "${order.oOrderStatus}"`);
                            });
                            
                            // Check if ANY fluid is ordered/dispatched/completed
                            const anyFluidOrdered = fluidOrders.some(order => 
                                ["Ordered", "Dispatched", "Completed"].includes(order.oOrderStatus)
                            );
                            
                            if (anyFluidOrdered) {
                                return "Y"; // At least one sepsis fluid ordered - resuscitation initiated
                            }
                        }
                    }
                }
            }
        }
        
        // No sepsis-specific fluid orders found
        this._logDebug('No sepsis-specific fluid orders found in PowerPlan phases');
        return "N";
    };
    
    /**
     * Determine Perfusion Assessment status with lactate-dependent conditional logic
     * CONDITIONAL DISPLAY LOGIC (From Sepsis Data Display Spec Aug 20, 2025):
     * 
     * Clinical Rule: Perfusion reassessment only indicated when lactate ≥ 4.0 mmol/L
     * Conditional Logic: Check lactate result FIRST, then assess intervention status
     * 
     * Lactate Result → Display Logic:
     * - LACTATE_RESULT < 4.0 → "N/A" (Gray) - Not clinically indicated per SEP-1 guidelines
     * - LACTATE_RESULT ≥ 4.0 → Check perfusion assessment data (Y/N/Pend when available)
     * - LACTATE_RESULT null/undefined → "N/A" (Gray) - Cannot determine indication
     * 
     * REQUESTOR TODO: Determine perfusion assessment data source
     * - Clinical charting/documentation? (not orders)
     * - Assessment methods: CVP, central venous oxygen, bedside CV ultrasound, fluid challenge, passive leg raise
     * - Current implementation: Returns "TBD" for lactate ≥ 4.0 until data source determined
     * 
     * @param {Object} patient - Patient data object
     * @returns {string} - Perfusion assessment status ("Y", "N", "Pend", "N/A", or "TBD")
     */

    /**
     * Determine Fluid Order details for enhanced tooltips with volume amounts (Casey's requirement)
     * Processes v14 fluids[] array to provide comprehensive tooltip data with Casey's "1000 ML at 10:52 AM" format
     *
     * @param {Object} patient - Patient data object with fluids array
     * @returns {Object} - Enhanced fluid object with volume details for tooltips
     */
    PatientDataService.prototype.determineFluidOrderedDetails = function(patient) {
        // Default response structure
        const defaultResponse = {
            status: "N",
            fluids: [],
            totalVolume: 0,
            overallStatus: "Not Ordered"
        };

        // v14 Enhanced: Use new fluids[] array for comprehensive tooltip data (Casey's requirement)
        if (patient.fluids && Array.isArray(patient.fluids) && patient.fluids.length > 0) {
            this._logDebug(`Processing v14 fluids[] array with ${patient.fluids.length} orders for tooltip details`);

            // v17 Enhancement: Filter out multi-ingredient IV drips (GitHub Issue #6)
            // v19 Enhancement: Filter out radiology/CT fluids (GitHub Issue #33)
            const pureFluidOrders = patient.fluids.filter(fluid => {
                // Exclude multi-ingredient
                if (fluid.multiIngredientInd !== 0) return false;

                // Exclude radiology/CT fluids (Issue #33, #75: Fixed CT false positives)
                const orderedAs = (fluid.orderedAsMnemonic || '').toUpperCase();
                if (orderedAs.includes('RADIOLOGY') || orderedAs.includes('FLUSH') || orderedAs.includes(' CT ')) {
                    this._logDebug(`v19: Excluding radiology fluid: ${fluid.orderMnemonic} (${fluid.orderedAsMnemonic})`);
                    return false;
                }

                return true;
            });

            this._logDebug(`v19 Tooltip details: Using ${pureFluidOrders.length} resuscitation fluids (excluded ${patient.fluids.length - pureFluidOrders.length} multi-ingredient/radiology)`);

            // Calculate total volume across pure crystalloid fluids only (Casey's cumulative requirement)
            const totalVolume = pureFluidOrders.reduce((sum, fluid) => sum + (fluid.totalVolumeMl || 0), 0);

            // Find administered pure crystalloid fluids for priority display
            const administeredFluids = pureFluidOrders.filter(fluid =>
                fluid.firstAdminDtTmDisp &&
                fluid.firstAdminDtTmDisp !== "" &&
                !fluid.firstAdminDtTmDisp.includes("1900-01-01")
            );

            // v23: Process ALL fluids for tooltip (not just pure crystalloids) - for troubleshooting
            console.log('🔧 [v23-DEBUG] PatientDataService.js LOADED - Issue #75 fluids enhancement ACTIVE');
            console.log('🔧 [v23-DEBUG] Total fluids:', patient.fluids.length);
            console.log('🔧 [v23-DEBUG] Pure crystalloids (counting):', pureFluidOrders.length);
            console.log('🔧 [v23-DEBUG] Excluded (multi-ingredient/radiology):', patient.fluids.length - pureFluidOrders.length);

            // v23: Map ALL fluids for tooltip (including excluded ones for troubleshooting)
            let fluidsDetails = patient.fluids
                .filter(fluid => {
                    // Still exclude radiology/CT fluids from tooltip (Issue #75: Fixed CT false positives)
                    const orderedAs = (fluid.orderedAsMnemonic || '').toUpperCase();
                    if (orderedAs.includes('RADIOLOGY') || orderedAs.includes('FLUSH') || orderedAs.includes(' CT ')) {
                        return false;
                    }
                    return true;
                })
                .map(fluid => ({
                    orderMnemonic: fluid.orderMnemonic,
                    primaryMnemonic: fluid.primaryMnemonic || fluid.orderMnemonic,  // v23: Standardized name (Issue #75)
                    orderId: fluid.orderId || 0,  // v23: For debugging (Issue #75)
                    catalogCd: fluid.catalogCd || 0,  // v23: In JSON only, not displayed (Issue #75)
                    orderedAs: fluid.orderedAsMnemonic || '', // Issue #33: Partial fluid & radiology detection
                    orderStatus: fluid.orderStatusDisp,
                    multiIngredient: fluid.multiIngredientInd === 1,  // v23: Flag for tooltip display
                    administered: fluid.firstAdminDtTmDisp && !fluid.firstAdminDtTmDisp.includes("1900-01-01"),
                    firstAdminTime: fluid.firstAdminDtTmDisp || "Not administered",
                    totalVolume: fluid.totalVolumeMl || 0,
                    administrations: fluid.administrations.map(admin => ({
                        volume: admin.adminVolumeMl,
                        time: admin.adminDtTmDisp,
                        route: admin.adminRoute
                    }))
                }));

            console.log('🔧 [v23-DEBUG] fluidsDetails (mapped - BEFORE limit):', fluidsDetails.length);

            // v23-TEMP: Limit to first 5 fluids for tooltip rendering (testing Issue #75)
            if (fluidsDetails.length > 5) {
                fluidsDetails = fluidsDetails.slice(0, 5);
                console.log('🔧 [v23-DEBUG] ⚠️ LIMITED to 5 fluids for tooltip');
            }

            console.log('🔧 [v23-DEBUG] fluidsDetails (FINAL):', fluidsDetails.length);
            if (fluidsDetails.length > 0) {
                console.log('🔧 [v23-DEBUG] First mapped fluid:', fluidsDetails[0]);
            }

            if (administeredFluids.length > 0) {
                return {
                    status: "Y",
                    fluids: fluidsDetails,
                    totalVolume: totalVolume,
                    overallStatus: "Administered",
                    firstAdministered: {
                        orderMnemonic: administeredFluids[0].orderMnemonic,
                        adminTime: administeredFluids[0].firstAdminDtTmDisp,
                        volume: administeredFluids[0].totalVolumeMl
                    },
                    totalOrders: pureFluidOrders.length, // v17: Count pure crystalloids only
                    administeredCount: administeredFluids.length
                };
            } else if (pureFluidOrders.length > 0) {
                // Pure crystalloid fluids ordered but none administered yet
                return {
                    status: "Pend",
                    fluids: fluidsDetails,
                    totalVolume: 0, // No administered volume yet
                    overallStatus: "Ordered - Pending Administration",
                    totalOrders: pureFluidOrders.length, // v17: Count pure crystalloids only
                    administeredCount: 0
                };
            } else {
                // All fluids were multi-ingredient (excluded)
                return defaultResponse;
            }
        }

        // No fluids found
        return defaultResponse;
    };

    PatientDataService.prototype.determinePerfusionAssessmentStatus = function(patient) {
        // REFACTORED (Issue #31): Remove lactate check - let renderer handle "N/A" based on hasSepticShockIndication()
        // This function now ONLY checks if perfusion was documented, not if it's clinically indicated

        this._logDebug(`Perfusion assessment - checking documentation status`);

        // Check for perfusion documentation in PowerForms or other sources
        // Currently returns "N" as placeholder until Dr. Crawford provides data source
        // Will be updated when perfusion assessment data source is identified

        return "N"; // Not documented - will show as empty circle when septic shock indicated
    };
    
    /**
     * Determine Vasopressors status with lactate-dependent conditional logic  
     * CONDITIONAL DISPLAY LOGIC (From Sepsis Data Display Spec Aug 20, 2025):
     * 
     * Clinical Rule: Vasopressors only indicated when lactate ≥ 4.0 mmol/L
     * Conditional Logic: Check lactate result FIRST, then assess intervention status
     * 
     * Lactate Result → Display Logic:
     * - LACTATE_RESULT < 4.0 → "N/A" (Gray) - Not clinically indicated per SEP-1 guidelines
     * - LACTATE_RESULT ≥ 4.0 → Check vasopressor orders (Y/N/Pend when available)
     * - LACTATE_RESULT null/undefined → "N/A" (Gray) - Cannot determine indication
     * 
     * REQUESTOR TODO: Determine vasopressor order data source
     * - PowerPlan analysis: No vasopressor orders found in ED Sepsis PowerPlans
     * - Likely separate medication orders (norepinephrine, dopamine, vasopressin)
     * - May be ICU-specific protocols not in ED PowerPlans
     * - Current implementation: Returns "TBD" for lactate ≥ 4.0 until data source determined
     * 
     * @param {Object} patient - Patient data object  
     * @returns {string} - Vasopressor status ("Y", "N", "Pend", "N/A", or "TBD")
     */
    PatientDataService.prototype.determinePressorsStatus = function(patient) {
        // REFACTORED (Issue #31): Remove lactate check - let renderer handle "N/A" based on hasSepticShockIndication()
        // This function now ONLY returns order status (Y/Pend/N), renderer decides when to show "N/A"

        try {
            this._logDebug('=== Determining Pressors Status ===');

            if (!patient || !patient.pressors || !Array.isArray(patient.pressors)) {
                this._logDebug('No pressors array found');
                return "N"; // No pressors detected
            }

            this._logDebug(`Found ${patient.pressors.length} pressor orders`);

            // Check if any pressor ordered/administered
            for (const pressor of patient.pressors) {
                this._logDebug(`Pressor: ${pressor.orderMnemonic} - Status: ${pressor.orderStatusDisp}`);

                // Check if pressor is ordered (any status except discontinued/canceled/voided/deleted)
                if (pressor.orderStatusDisp &&
                    !["Discontinued", "Canceled", "Voided", "Deleted"].includes(pressor.orderStatusDisp)) {

                    // Check if administered
                    if (pressor.totalAdministrations > 0) {
                        this._logDebug(`Pressors: Y (administered) - ${pressor.orderMnemonic}`);
                        return "Y"; // Administered - green check
                    } else {
                        this._logDebug(`Pressors: Pend (ordered but not administered) - ${pressor.orderMnemonic}`);
                        return "Pend"; // Ordered but not administered - yellow pending
                    }
                }
            }

            this._logDebug('No active pressor orders found - returning N');
            return "N"; // No pressors ordered
        } catch (error) {
            this._logDebug('ERROR in determinePressorsStatus:', error.message);
            console.error('PRESSORS STATUS ERROR:', error);
            return "N"; // Fallback on error
        }
    };
    
    /**
     * Determine Volume Documentation status with fluids-dependent conditional logic
     * FLUIDS-DEPENDENT CONDITIONAL LOGIC (Cross-Column Dependency):
     * 
     * Clinical Rule: Volume documentation only relevant when fluids are ordered/administered
     * Conditional Logic: Check FLUIDS status FIRST, then assess documentation relevance
     * 
     * Fluids Status → Vol Doc Display Logic:
     * - FLUIDS = "N" (no fluids) → "--" (Not applicable - no fluids to document)
     * - FLUIDS = "Pend" (fluids planned) → "--" (Not applicable - fluids not started)
     * - FLUIDS = "Y" (fluids ordered) → "TBD" (Documentation relevant, awaiting data source)
     * 
     * REQUESTOR TODO: Determine volume documentation data source
     * - Clinical charting/assessment? (likely nursing documentation)
     * - Fluid intake/output records?
     * - IV pump documentation?
     * - Manual charting vs automated calculation?
     * - Current implementation: Returns "TBD" when fluids ordered until data source determined
     * 
     * Clinical Workflow: Fluids → Administration → Volume Documentation
     * SEP-1 Bundle: Volume documentation follows 30 mL/kg crystalloid administration
     * 
     * @param {Object} patient - Patient data object
     * @returns {string} - Volume documentation status ("Y", "N", "Pend", "--", or "TBD")
     */
    PatientDataService.prototype.determineVolumeDocumentationStatus = function(patient) {
        // Check if Volume Documentation status is already pre-computed (from mock data)
        if (patient.FLUID_VOLUME_DOCUMENTED) {
            this._logDebug(`Using pre-computed Volume Documentation status: ${patient.FLUID_VOLUME_DOCUMENTED}`);
            return patient.FLUID_VOLUME_DOCUMENTED;
        }
        
        // Get fluids status to determine if volume documentation is applicable
        const fluidsStatus = this.determineFluidOrderedStatus(patient);
        
        this._logDebug(`Vol Doc - checking fluids status first: ${fluidsStatus}`);
        
        // Fluids-dependent conditional logic
        if (fluidsStatus === "N" || fluidsStatus === "Pend") {
            this._logDebug(`Vol Doc: -- (fluids ${fluidsStatus}) - documentation not applicable`);
            return "--"; // Not applicable - no fluids ordered/administered to document
        } else if (fluidsStatus === "Y") {
            this._logDebug(`Vol Doc: TBD (fluids ${fluidsStatus}) - documentation relevant but data source pending`);
            // REQUESTOR TODO: Determine volume documentation data source
            return "TBD"; // Fluids ordered - documentation relevant but data source pending
        }
        
        // Fallback for unexpected fluids status
        this._logDebug(`Vol Doc: unexpected fluids status: ${fluidsStatus}`);
        return "--";
    };
    
    /**
     * Determine Time Zero status based on earliest sepsis identification (v07 enhanced)
     * EARLIEST IDENTIFICATION LOGIC (From Enhanced CCL v07 with timeZero array):
     * 
     * Clinical Rule: Time Zero = earliest sepsis identification (alert OR diagnosis)
     * Data Sources: Alert events + Diagnosis events in unified timeZero array
     * 
     * Time Zero → Display Logic:
     * - Valid earliest timestamp → Display earliest identification (e.g., "12/09/24 12:45")
     * - Events exist but no timestamps → Display "Date NA" (timestamp validation needed)
     * - No sepsis events → Display "--" (no Time Zero established)
     * 
     * Real Data Example (From Console - VEST, CAROL SUE):
     * timeZero: [
     *   { type: "Diagnosis", diagDtTmDisp: "12/09/24 16:15" },  // Later
     *   { type: "Alert", eventEndDtTmDisp: "12/09/24 12:45" }   // Earlier ← Time Zero
     * ]
     * 
     * SEP-1 Bundle Foundation: Time Zero from earliest identification for accurate bundle timing
     * Clinical Workflow: Alert/Diagnosis → Time Zero → Bundle timer activation
     * 
     * @param {Object} patient - Patient data object with timeZero array (v07)
     * @returns {string} - Time Zero timestamp, "Date NA", or "--"
     */
    PatientDataService.prototype.determineTimeZeroStatus = function(patient) {
        // Check if Time Zero status is already pre-computed (from mock data)
        if (patient.LAST_SEPSIS_SCREEN) {
            this._logDebug(`Using pre-computed Time Zero: ${patient.LAST_SEPSIS_SCREEN}`);
            return patient.LAST_SEPSIS_SCREEN;
        }
        
        // Check for timeZero data in patient object (v07 enhanced structure)
        if (!patient.timeZero || !Array.isArray(patient.timeZero) || patient.timeZero.length === 0) {
            this._logDebug('No timeZero data found - Time Zero not established');
            return ""; // Dashboard cleanup (Issue #31) - blank instead of "--"
        }
        
        this._logDebug(`Found ${patient.timeZero.length} timeZero events - processing for earliest identification`);
        
        // Extract timestamps from all events (alert and diagnosis)
        const eventsWithTimestamps = patient.timeZero.map(event => {
            let timestamp = null;
            
            if (event.type === "Alert" && event.eventEndDtTmDisp) {
                timestamp = event.eventEndDtTmDisp;
            } else if (event.type === "Diagnosis" && event.diagDtTmDisp) {
                timestamp = event.diagDtTmDisp;
            }
            
            return {
                ...event,
                extractedTimestamp: timestamp,
                hasValidTimestamp: timestamp && timestamp.trim() !== ''
            };
        });
        
        // Filter to events with valid timestamps
        const validEvents = eventsWithTimestamps.filter(event => event.hasValidTimestamp);
        
        this._logDebug(`Valid timestamp events: ${validEvents.length} out of ${patient.timeZero.length}`);
        
        if (validEvents.length === 0) {
            this._logDebug('TimeZero events exist but no valid timestamps found - development validation needed');
            return "Date NA"; // Events exist but no valid timestamps for development validation
        }
        
        // Sort by timestamp to find earliest identification
        const sortedEvents = validEvents.sort((a, b) => {
            const dateA = this.parseTimeZeroDate(a.extractedTimestamp);
            const dateB = this.parseTimeZeroDate(b.extractedTimestamp);
            return dateA.getTime() - dateB.getTime();
        });
        
        const earliestEvent = sortedEvents[0];
        this._logDebug(`Earliest sepsis identification: ${earliestEvent.type} at ${earliestEvent.extractedTimestamp}`);
        
        return earliestEvent.extractedTimestamp; // Return earliest identification timestamp
    };

    /**
     * Determine Time Zero source details for tooltips (Casey's accountability requirement)
     * Shows whether Time Zero came from Alert or Diagnosis for fallout analysis
     *
     * @param {Object} patient - Patient data object with timeZero array
     * @returns {Object} - Time Zero details with source information
     */
    PatientDataService.prototype.determineTimeZeroDetails = function(patient) {
        // Default response structure
        const defaultResponse = {
            source: "None",
            sourceType: "None",
            sourceDisplay: "No Time Zero established",
            timestamp: "--",
            details: "No sepsis identification events found"
        };

        // Check for timeZero data in patient object
        if (!patient.timeZero || !Array.isArray(patient.timeZero) || patient.timeZero.length === 0) {
            this._logDebug('No timeZero data found for source details');
            return defaultResponse;
        }

        // Process each Time Zero event to extract timestamp and determine source
        const eventsWithTimestamps = patient.timeZero.map(event => {
            let timestamp = null;
            let sourceDisplay = "";
            let details = "";

            if (event.type === "Diagnosis") {
                timestamp = event.diagDtTmDisp;
                sourceDisplay = `Diagnosis: ${event.diagDisplay}`;
                details = `Provider diagnosis of "${event.diagDisplay}" documented in patient record`;
            } else if (event.type === "Alert") {
                timestamp = event.eventEndDtTmDisp;
                sourceDisplay = `Alert: ${event.resultVal}`;
                details = `Automated sepsis alert "${event.resultVal}" triggered by clinical criteria`;
            }

            return {
                ...event,
                extractedTimestamp: timestamp,
                sourceDisplay: sourceDisplay,
                details: details,
                hasValidTimestamp: timestamp && timestamp.trim() !== ''
            };
        });

        // Filter to events with valid timestamps and sort chronologically
        const validEvents = eventsWithTimestamps.filter(event => event.hasValidTimestamp);

        if (validEvents.length === 0) {
            return {
                source: "Unknown",
                sourceType: "Data Issue",
                sourceDisplay: "Time Zero events exist but timestamps unavailable",
                timestamp: "Date NA",
                details: "Events found but missing valid timestamps for Time Zero calculation"
            };
        }

        // Sort chronologically to find earliest (actual Time Zero source)
        validEvents.sort((a, b) => {
            const timeA = new Date(a.extractedTimestamp.replace(/(\d{2})\/(\d{2})\/(\d{2})/, '20$3-$1-$2'));
            const timeB = new Date(b.extractedTimestamp.replace(/(\d{2})\/(\d{2})\/(\d{2})/, '20$3-$1-$2'));
            return timeA - timeB;
        });

        const earliestEvent = validEvents[0];
        this._logDebug(`Time Zero source determined: ${earliestEvent.type} at ${earliestEvent.extractedTimestamp}`);

        return {
            source: earliestEvent.type,
            sourceType: earliestEvent.type,
            sourceDisplay: earliestEvent.sourceDisplay,
            timestamp: earliestEvent.extractedTimestamp,
            details: earliestEvent.details,
            totalSources: validEvents.length,
            allSources: validEvents.map(e => `${e.type}: ${e.extractedTimestamp}`).join(", ")
        };
    };

    /**
     * Determine Timer (countdown to 3-hour SEP-1 bundle deadline) based on Time Zero column
     * TIMER CALCULATION LOGIC (Enhancement 2 - Countdown Timer):
     *
     * Timer Format Rules:
     * - Remaining time: Display as "Xm left" or "Xh Ym left" (e.g., "45m left", "1h 30m left")
     * - Overdue: Display as "OVERDUE Xm" or "OVERDUE Xh Ym" (e.g., "OVERDUE 15m", "OVERDUE 1h 20m")
     *
     * Time Zero Dependency:
     * - Time Zero = "--" (no diagnosis) → Timer = "--" (no timer established)
     * - Time Zero = "TBD" (diagnosis exists, date research needed) → Timer = "TBD" (pending Time Zero)
     * - Time Zero = formatted date → Timer = calculated countdown (3 hours - elapsed time)
     *
     * Calculation: 3 hours (180 minutes) - (Current Date/Time - Time Zero Date/Time) = Remaining Time
     * SEP-1 Bundle Context: Timer shows countdown for 3-hour bundle completion deadline
     *
     * @param {Object} patient - Patient data object
     * @returns {string} - Timer display ("Xm left", "Xh Ym left", "OVERDUE", "TBD", or "--")
     */
    PatientDataService.prototype.determineTimerStatus = function(patient) {
        // Check if Timer is already pre-computed (from mock data)
        if (patient.SEPSIS_TIMER) {
            this._logDebug(`Using pre-computed Timer: ${patient.SEPSIS_TIMER}`);
            return patient.SEPSIS_TIMER;
        }

        // Get Time Zero status to determine if timer is applicable
        const timeZeroStatus = this.determineTimeZeroStatus(patient);

        this._logDebug(`Timer - checking Time Zero first: ${timeZeroStatus}`);

        // Time Zero dependency logic (Dashboard cleanup Issue #31 - return blank instead of "--")
        if (timeZeroStatus === "--" || timeZeroStatus === "") {
            this._logDebug('Timer: blank (no Time Zero established) - no timer applicable');
            return ""; // No Time Zero - no timer (blank for clean dashboard)
        } else if (timeZeroStatus === "Date NA") {
            this._logDebug('Timer: blank (Time Zero events exist but no valid timestamps) - timer calculation impossible');
            return ""; // Clean dashboard - cannot calculate without valid timestamp
        } else if (timeZeroStatus === "TBD") {
            this._logDebug('Timer: TBD (Time Zero pending research) - timer calculation pending');
            return "TBD"; // Legacy fallback for old logic
        }

        // Time Zero has formatted date - calculate countdown from 3-hour deadline
        try {
            // Parse Time Zero date/time (format: "MM/DD/YY HH:MM")
            const timeZeroDate = this.parseTimeZeroDate(timeZeroStatus);
            const currentDate = new Date();

            if (!timeZeroDate || isNaN(timeZeroDate.getTime())) {
                this._logDebug(`Timer: TBD - cannot parse Time Zero date: ${timeZeroStatus}`);
                return "TBD"; // Cannot parse Time Zero date
            }

            // Calculate elapsed time in minutes
            const elapsedMs = currentDate.getTime() - timeZeroDate.getTime();
            const elapsedMinutes = Math.floor(elapsedMs / (1000 * 60));

            // SEP-1 bundle deadline: 3 hours = 180 minutes
            const BUNDLE_DEADLINE_MINUTES = 180;
            const remainingMinutes = BUNDLE_DEADLINE_MINUTES - elapsedMinutes;

            this._logDebug(`Timer countdown: ${elapsedMinutes} minutes elapsed, ${remainingMinutes} minutes remaining until 3-hour deadline`);

            // Format as countdown with remaining time or overdue status
            return this.formatCountdownTime(remainingMinutes);

        } catch (error) {
            this._logDebug(`Timer calculation error: ${error.message}`);
            return "TBD"; // Calculation error - needs investigation
        }
    };
    
    /**
     * Determine Timer Sort Value - numeric minutes for proper sorting
     * Returns raw minutes remaining (positive = time left, negative = overdue)
     * This allows proper numeric sorting instead of alphabetical text sorting
     *
     * @param {Object} patient - Patient data object
     * @returns {number|null} - Minutes remaining (null for "--" or "TBD")
     */
    PatientDataService.prototype.determineTimerSortValue = function(patient) {
        // Get Time Zero status to determine if timer is applicable
        const timeZeroStatus = this.determineTimeZeroStatus(patient);

        // Return null for non-applicable cases (sorts to bottom)
        if (timeZeroStatus === "--" || timeZeroStatus === "Date NA" || timeZeroStatus === "TBD") {
            return null;
        }

        // Calculate remaining minutes (same logic as determineTimerStatus)
        try {
            const timeZeroDate = this.parseTimeZeroDate(timeZeroStatus);
            const currentDate = new Date();

            if (!timeZeroDate || isNaN(timeZeroDate.getTime())) {
                return null;
            }

            // Calculate elapsed time in minutes
            const elapsedMs = currentDate.getTime() - timeZeroDate.getTime();
            const elapsedMinutes = Math.floor(elapsedMs / (1000 * 60));

            // SEP-1 bundle deadline: 3 hours = 180 minutes
            const BUNDLE_DEADLINE_MINUTES = 180;
            const remainingMinutes = BUNDLE_DEADLINE_MINUTES - elapsedMinutes;

            return remainingMinutes; // Positive = time left, negative = overdue

        } catch (error) {
            return null;
        }
    };

    /**
     * Parse Time Zero date string to Date object
     * @param {string} timeZeroString - Time Zero formatted string (e.g., "09/10/25 20:01")
     * @returns {Date} - Parsed Date object or null if parsing fails
     */
    PatientDataService.prototype.parseTimeZeroDate = function(timeZeroString) {
        try {
            // Expected format: "MM/DD/YY HH:MM" (e.g., "09/10/25 20:01")
            const [datePart, timePart] = timeZeroString.split(' ');
            const [month, day, year] = datePart.split('/');
            const [hours, minutes] = timePart.split(':');
            
            // Convert 2-digit year to 4-digit (assume 20xx)
            const fullYear = parseInt('20' + year);
            
            return new Date(fullYear, parseInt(month) - 1, parseInt(day), parseInt(hours), parseInt(minutes));
        } catch (error) {
            this._logDebug(`Error parsing Time Zero date: ${error.message}`);
            return null;
        }
    };
    
    /**
     * Format countdown time for SEP-1 bundle deadline (Enhancement 2)
     * Always displays hours with leading zero for consistent sorting
     * Format: "Xh YYm" (e.g., "2h 50m", "0h 45m", "0h 05m")
     * Clean, concise format - column header provides context
     *
     * @param {number} minutes - Remaining minutes (positive = time left, negative = overdue)
     * @returns {string} - Formatted countdown display with consistent format
     */
    PatientDataService.prototype.formatCountdownTime = function(minutes) {
        // If overdue (negative), set to 0
        if (minutes < 0) {
            minutes = 0;
        }

        // Always format as "Xh YYm" for consistent sorting and clean display
        const hours = Math.floor(minutes / 60);
        const remainingMinutes = minutes % 60;

        // Pad minutes with leading zero if < 10 for better sorting
        const paddedMinutes = remainingMinutes < 10 ? `0${remainingMinutes}` : remainingMinutes;

        return `${hours}h ${paddedMinutes}m`;
    };

    /**
     * Format elapsed time according to enhanced spec rules (includes days for multi-day stays)
     * DEPRECATED: Replaced by formatCountdownTime for Enhancement 2
     * Kept for backwards compatibility if needed
     * @param {number} minutes - Elapsed minutes
     * @returns {string} - Formatted timer display
     */
    PatientDataService.prototype.formatElapsedTime = function(minutes) {
        if (minutes < 0) {
            return "0m"; // Handle negative time (shouldn't happen but safety)
        }

        if (minutes < 60) {
            // Under 1 hour: Display as "Xm"
            return `${minutes}m`;
        } else if (minutes < 1440) {
            // 1-23 hours: Display as "Xh Ym" (1440 minutes = 24 hours)
            const hours = Math.floor(minutes / 60);
            const remainingMinutes = minutes % 60;
            return `${hours}h ${remainingMinutes}m`;
        } else {
            // 24+ hours: Display as "Xd Yh Zm" for multi-day patient stays
            const days = Math.floor(minutes / 1440);
            const remainingMinutes = minutes % 1440;
            const hours = Math.floor(remainingMinutes / 60);
            const finalMinutes = remainingMinutes % 60;
            return `${days}d ${hours}h ${finalMinutes}m`;
        }
    };
    
    /**
     * Determine Alert Type status based on clinical event data
     * SIMPLE ALERT DISPLAY LOGIC (From Enhanced CCL v04):
     * 
     * Alert Data Source: Clinical event data with sepsis-related alerts
     * Display Logic: Show actual resultVal from alert events
     * 
     * Alert → Display Logic:
     * - Alert events found → Display resultVal (e.g., "Severe Sepsis")
     * - No alert events → Display "--" (no alerts)
     * 
     * Real Data Example (From Console - ZZTEST, SEPSISONE):
     * alert: [{
     *   eventTag: "Severe Sepsis",
     *   resultVal: "Severe Sepsis",  // DISPLAY THIS VALUE
     *   eventCdDisp: "Recommendation - Action"
     * }]
     * 
     * Clinical Context: Shows actual sepsis alert values from clinical events
     * Simple Implementation: Text display without visual styling (for now)
     * 
     * @param {Object} patient - Patient data object with alert array
     * @returns {string} - Alert display value or "--" if no alerts
     */
    PatientDataService.prototype.determineAlertTypeStatus = function(patient) {
        // Check if Alert Type is already pre-computed (from mock data)
        if (patient.ALERT_TYPE) {
            this._logDebug(`Using pre-computed Alert Type: ${patient.ALERT_TYPE}`);
            return patient.ALERT_TYPE;
        }
        
        // Check for alert data in patient object
        if (!patient.alert || !Array.isArray(patient.alert) || patient.alert.length === 0) {
            this._logDebug('No alert data found - no sepsis alerts');
            return "--"; // No alert data available
        }
        
        // Get the first/primary alert event (assuming most recent or primary)
        const primaryAlert = patient.alert[0];
        
        if (primaryAlert && primaryAlert.resultVal) {
            this._logDebug(`Found alert event: eventTag="${primaryAlert.eventTag}", resultVal="${primaryAlert.resultVal}"`);
            return primaryAlert.resultVal; // Display the actual result value
        }
        
        // Alert array exists but no result value
        this._logDebug('Alert data exists but no resultVal found');
        return "--";
    };

    /**
     * Determine Alert details with criteria information from BLOB data for tooltip display
     * Returns enhanced object with alert and criteria details for Casey's hover requirements
     * @param {Object} patient - Patient data object
     * @returns {Object} - Enhanced alert object with criteria data
     */
    PatientDataService.prototype.determineAlertDetails = function(patient) {
        // Default response structure
        const defaultResponse = {
            hasAlert: false,
            alertTime: null,
            eventTag: null,
            criteriaList: [],
            rawCriteria: null
        };

        // Check for alert data with BLOB criteria
        if (patient.alert && Array.isArray(patient.alert) && patient.alert.length > 0) {
            // Get most recent alert (first in array)
            const latestAlert = patient.alert[0];

            if (latestAlert) {
                const alertDetails = {
                    hasAlert: true,
                    alertTime: latestAlert.eventEndDtTmDisp || null,
                    eventTag: latestAlert.eventTag || null,
                    criteriaList: [],
                    rawCriteria: latestAlert.resultComments || null
                };

                // Parse criteria data if BLOB data exists
                if (latestAlert.resultComments) {
                    const rawCriteria = latestAlert.resultComments;
                    this._logDebug(`Found alert with criteria BLOB: "${rawCriteria.substring(0, 100)}..."`);

                    // Remove GUID prefix (everything before first pipe)
                    let cleanedCriteria = rawCriteria;
                    const firstPipeIndex = rawCriteria.indexOf('|');
                    if (firstPipeIndex > 0) {
                        cleanedCriteria = rawCriteria.substring(firstPipeIndex + 1);
                        this._logDebug(`Removed GUID prefix, cleaned criteria: "${cleanedCriteria.substring(0, 100)}..."`);
                    }

                    // Split criteria by pipes and clean up
                    const criteriaArray = cleanedCriteria.split('|')
                        .map(criteria => criteria.trim())
                        .filter(criteria => criteria.length > 0);

                    alertDetails.criteriaList = criteriaArray;
                    this._logDebug(`Split into ${criteriaArray.length} criteria items`);
                }

                this._logDebug('Alert details captured: ' + JSON.stringify(alertDetails));
                return alertDetails;
            }
        }

        // No alert data found
        this._logDebug('No alert data with criteria found');
        return defaultResponse;
    };

    /**
     * Determine Lactate Result value from initial lactate clinical event data
     * LACTATE RESULT PROCESSING (From Enhanced CCL v05):
     * 
     * Data Source: Initial lactate clinical event results from lab
     * Display Logic: Show actual numeric lactate value with critical highlighting
     * 
     * Lactate Result → Display Logic:
     * - Initial lactate found → Display resultVal (e.g., "5.0", "2.3", "8.4")
     * - Critical value (≥ 4.0) → Pink background, red text, bold
     * - Normal value (< 4.0) → Standard numeric display
     * - No lactate result → Display "--" (no result available)
     * 
     * Real Data Example (From Console - ZZTEST, SEPSISONE):
     * initialLactate: [{
     *   clinicalEventId: 7447570950,
     *   eventCdDisp: "Lactic Acid, Whole Blood",
     *   eventTag: "5.0",
     *   resultVal: "5.0"  // CRITICAL VALUE - Display with highlighting
     * }]
     * 
     * Critical Value Threshold: ≥ 4.0 mmol/L (triggers perfusion/pressor protocols)
     * Clinical Context: Real lab result integration for accurate lactate monitoring
     * 
     * @param {Object} patient - Patient data object with initialLactate array
     * @returns {string} - Lactate result value or "--" if no result
     */
    PatientDataService.prototype.determineLactateResultValue = function(patient) {
        // Check if Lactate Result is already pre-computed (from mock data)
        if (patient.LACTATE_RESULT) {
            this._logDebug(`Using pre-computed Lactate Result: ${patient.LACTATE_RESULT}`);
            return patient.LACTATE_RESULT;
        }
        
        // v12 Enhanced: Use new lactate[] array for result values
        if (patient.lactate && Array.isArray(patient.lactate) && patient.lactate.length > 0) {
            // Filter out cancelled orders and find first order with result
            const activeLactates = patient.lactate.filter(order => order.cancelledInd !== 1);

            for (const lactateOrder of activeLactates) {
                if (lactateOrder.resultVal && lactateOrder.resultVal !== "" && lactateOrder.resultVal !== "0") {
                    const lactateValue = lactateOrder.resultVal;
                    this._logDebug(`Found lactate result from v12: order=${lactateOrder.orderMnemonic}, result=${lactateValue}`);

                    // Log critical value status for clinical awareness
                    const numericValue = parseFloat(lactateValue);
                    if (!isNaN(numericValue) && numericValue >= 4.0) {
                        this._logDebug(`CRITICAL LACTATE VALUE: ${lactateValue} ≥ 4.0 - triggers perfusion/pressor protocols`);
                    }

                    return lactateValue; // Display the actual lactate result value
                }
            }

            this._logDebug('v12 lactate orders found but no results available yet');
            return "--"; // Orders exist but no results yet
        }

        // Fallback to old initialLactate structure for backward compatibility
        if (!patient.initialLactate || !Array.isArray(patient.initialLactate) || patient.initialLactate.length === 0) {
            this._logDebug('No lactate[] array and no initialLactate data found');
            return "--"; // No lactate result data available
        }

        // Legacy: Get the first/primary lactate result
        const primaryLactate = patient.initialLactate[0];

        if (primaryLactate && primaryLactate.resultVal) {
            const lactateValue = primaryLactate.resultVal;
            this._logDebug(`Found initial lactate result: eventCdDisp="${primaryLactate.eventCdDisp}", resultVal="${lactateValue}"`);

            // Log critical value status for clinical awareness
            const numericValue = parseFloat(lactateValue);
            if (!isNaN(numericValue) && numericValue >= 4.0) {
                this._logDebug(`CRITICAL LACTATE VALUE: ${lactateValue} ≥ 4.0 - triggers perfusion/pressor protocols`);
            }

            return lactateValue; // Display the actual lactate result value
        }
        
        // Initial lactate array exists but no result value
        this._logDebug('Initial lactate data exists but no resultVal found');
        return "--";
    };
    
    /**
     * Determine Lactate 2 (Repeat Lactate) status with comprehensive clinical decision support logic
     * TWO-LAYER LACTATE 2 LOGIC - Clinical Decision Support + Order Status Tracking:
     * 
     * Layer 1: Initial Lactate Threshold Check (SEP-1 6-Hour Bundle Indication)
     * - Initial lactate < 4.0 → "N/A" (repeat lactate not clinically indicated)
     * - Initial lactate ≥ 4.0 → Proceed to Layer 2 (repeat lactate clinically indicated)
     * 
     * Layer 2: Repeat Lactate Order Status Check (When Clinically Indicated)
     * - No repeatLactate data → "N" (⚪ Gray empty - clinically required but not ordered)
     * - Has repeatLactate data → Check order status:
     *   - "Completed" → "Y" (✅ Green checkmark - repeat lactate completed)
     *   - "Dispatched/Ordered" → "Pend" (🟡 Yellow pending - repeat lactate in progress)
     * 
     * Clinical Decision Support Purpose:
     * - Shows "N" when repeat lactate is clinically required but automation/ordering failed
     * - Visual reminder: "This patient NEEDS repeat lactate due to critical initial value"
     * - SEP-1 bundle compliance: Highlights missing 6-hour bundle component
     * - Automation backup: Shows need even if Discern expert rule failed
     * 
     * Real Data Context (ZZTEST, SEPSISONE):
     * - Initial lactate: "5.0" (≥ 4.0 - repeat indicated)
     * - repeatLactate: [] (empty - not ordered)
     * - Expected result: "N" (gray empty - needed but not ordered)
     * 
     * @param {Object} patient - Patient data object with initialLactate and repeatLactate arrays
     * @returns {string} - Repeat lactate status ("Y", "N", "Pend", or "N/A")
     */
    PatientDataService.prototype.determineLactate2Status = function(patient) {
        // REFACTORED (Issue #31): Remove "N/A" logic - let renderer handle based on hasSepticShockIndication()
        // This function now ONLY returns order status (Y/Pend/N), renderer decides when to show "N/A"

        // Check if Lactate 2 status is already pre-computed (from mock data)
        if (patient.REPEAT_LACTATE_ORDERED) {
            this._logDebug(`Using pre-computed Lactate 2 status: ${patient.REPEAT_LACTATE_ORDERED}`);
            return patient.REPEAT_LACTATE_ORDERED;
        }

        this._logDebug(`Lac 2 - checking repeat lactate orders`);

        // v12 Enhanced: Use new lactate[] array for repeat lactate detection
        if (patient.lactate && Array.isArray(patient.lactate) && patient.lactate.length > 0) {
            // Filter out cancelled orders
            const activeLactates = patient.lactate.filter(order => order.cancelledInd !== 1);

            if (activeLactates.length < 2) {
                this._logDebug(`Lac 2: N (only ${activeLactates.length} active lactate orders found) - repeat lactate needed`);
                return "N"; // Only first lactate found, repeat needed
            }

            // Get second lactate order (chronologically)
            const secondLactate = activeLactates[1];
            this._logDebug(`Found second lactate: ${secondLactate.orderMnemonic}, Status: ${secondLactate.orderStatusDisp}`);

            // Map Cerner order status to our display logic
            const orderStatus = secondLactate.orderStatusDisp;
            if (orderStatus === "Completed" || orderStatus === "Dispatched") {
                return "Y"; // Completed or in progress
            } else if (orderStatus === "Ordered") {
                return "Pend"; // Ordered but not yet processed
            } else {
                return "N"; // Other statuses
            }
        }

        // Fallback to old repeat lactate structure for backward compatibility
        if (!patient.repeatLactate || !Array.isArray(patient.repeatLactate) || patient.repeatLactate.length === 0) {
            this._logDebug('Lac 2: N (no lactate[] array and no repeatLactate data) - repeat lactate needed due to critical initial value');
            return "N"; // Clinically required but not ordered (automation failure or clinical gap)
        }

        // Legacy: Has repeat lactate data - check order status
        const repeatLactateOrder = patient.repeatLactate[0]; // Get first/primary repeat lactate
        
        if (repeatLactateOrder && repeatLactateOrder.oOrderStatus) {
            this._logDebug(`Found repeat lactate order with status: ${repeatLactateOrder.oOrderStatus}`);
            
            // Apply same completion-focused logic as initial lactate
            switch (repeatLactateOrder.oOrderStatus) {
                case "Completed":
                    return "Y"; // Green checkmark - repeat lactate completed
                case "Dispatched":
                case "Ordered":
                    return "Pend"; // Yellow pending - repeat lactate in progress
                default:
                    this._logDebug(`Unknown repeat lactate order status: ${repeatLactateOrder.oOrderStatus}`);
                    return "Pend"; // Conservative default
            }
        }
        
        // Has repeat lactate data but no order status
        this._logDebug('Repeat lactate data exists but no order status found');
        return "N"; // Data exists but incomplete
    };
    
    /**
     * Determine Sepsis Screening Assessment status from PowerForm documentation
     * POWERFORM ASSESSMENT INTEGRATION (Placeholder for v06 CCL):
     * 
     * Data Source: Sepsis screening PowerForm with clinical assessment documentation
     * Assessment Options: Ruled Out, Sepsis Confirmed, Septic Shock Confirmed, Cannot Determine
     * 
     * PowerForm Options → Display Values:
     * - "Severe Sepsis/Septic Shock ruled out" → "Ruled Out"
     * - "Severe Sepsis has been confirmed" → "Severe Sepsis"
     * - "Septic Shock/Severe Sepsis with hypotension confirmed" → "Septic Shock"
     * - "I cannot determine" → "Cannot Determine"
     * - No assessment → "--" (PowerForm not completed)
     * 
     * Clinical Context: Formal sepsis assessment documentation from clinical staff
     * Workflow: Provider completes PowerForm assessment → Results display in Screen column
     * 
     * REQUESTOR TODO: Determine PowerForm data source location and field mapping
     * - PowerForm table/view in Cerner for sepsis screening results
     * - Field names for assessment selections
     * - Query approach for PowerForm completion data
     * 
     * @param {Object} patient - Patient data object with PowerForm assessment data (when available)
     * @returns {string} - Screening assessment status or "TBD" until data source available
     */
    /**
     * Determine Screen assessment details with criteria information for tooltip display
     * Returns enhanced object with assessment and alert criteria details for Casey's hover requirements
     *
     * CERNER IMPLEMENTATION NOTE:
     * - Current: Mock data with simulated alert criteria and comments
     * - Future: Will map from actual Cerner rule result comment field (varchar)
     * - Framework ready for adaptation when real result comment field structure is available
     * - Tooltip content will be populated from Cerner's actual result comment data
     *
     * @param {Object} patient - Patient data object
     * @returns {Object} - Enhanced screen object with assessment and criteria data
     */
    PatientDataService.prototype.determineScreenAssessmentDetails = function(patient) {
        // Default response structure (based on real Cerner fields)
        const defaultResponse = {
            assessment: "--",
            completedDateTime: null,
            eventId: null,
            clinicalEventId: null,
            eventCdDisp: null,
            resultVal: null
        };

        // Check for PowerForm screen assessment data (v06 CCL structure)
        if (patient.screen && Array.isArray(patient.screen) && patient.screen.length > 0) {
            // Get most recent assessment (first in array)
            const latestAssessment = patient.screen[0];

            if (latestAssessment && latestAssessment.resultVal) {
                const assessmentText = latestAssessment.resultVal;
                this._logDebug(`Found PowerForm sepsis assessment: "${assessmentText}"`);

                // Capture real Cerner screen assessment information including physician data (v08)
                const screenDetails = {
                    resultVal: assessmentText,
                    completedDateTime: latestAssessment.eventEndDtTmDisp || null, // Real Cerner field
                    eventId: latestAssessment.eventId || null,
                    clinicalEventId: latestAssessment.clinicalEventId || null,
                    eventCdDisp: latestAssessment.eventCdDisp || null,
                    // NEW v08 fields: Physician information from CCL enhancement
                    performedPrsnlId: latestAssessment.performedPrsnlId || null,
                    performedPrsnlName: latestAssessment.performedPrsnlName || null,
                    performedPrsnlPosition: latestAssessment.performedPrsnlPosition || null
                };

                // Map PowerForm responses to display values
                if (assessmentText.includes('ruled out')) {
                    screenDetails.assessment = "Ruled Out";
                } else if (assessmentText.includes('Septic Shock') || assessmentText.includes('hypotension')) {
                    screenDetails.assessment = "Septic Shock";
                } else if (assessmentText.includes('Severe Sepsis has been confirmed')) {
                    screenDetails.assessment = "Severe Sepsis";
                } else if (assessmentText.includes('cannot determine')) {
                    screenDetails.assessment = "Cannot Determine";
                } else {
                    // Unknown assessment type
                    this._logDebug(`Unknown PowerForm assessment: ${assessmentText}`);
                    screenDetails.assessment = "Cannot Determine"; // Conservative default
                }

                console.log('📋 REAL SCREEN ASSESSMENT:', latestAssessment);
                console.log('📋 SCREEN DETAILS:', screenDetails);
                return screenDetails;
            }
        }

        // Check if pre-computed data available
        if (patient.SEPSIS_SCREEN_ASSESSMENT) {
            this._logDebug(`Using pre-computed Screening Assessment: ${patient.SEPSIS_SCREEN_ASSESSMENT}`);
            defaultResponse.assessment = patient.SEPSIS_SCREEN_ASSESSMENT;
            return defaultResponse;
        }

        // No PowerForm assessment data found
        this._logDebug('No PowerForm assessment data found - no sepsis screening completed');
        return defaultResponse;
    };

    /**
     * Determine perfusion PowerForm assessment details (v20 - Issue #47)
     * Parses perfusion[] array from CCL v20 to extract completion data
     *
     * @param {Object} patient - Patient data from CCL
     * @returns {Object} Perfusion details with completion info for tooltip
     */
    PatientDataService.prototype.determinePerfusionDetails = function(patient) {
        // Default response structure
        const defaultResponse = {
            completed: false,
            completedDateTime: null,
            performedPrsnlName: null,
            performedPrsnlPosition: null,
            eventCdDisp: null,
            resultVal: null,
            clinicalEventId: null,
            eventId: null
        };

        // Check for perfusion PowerForm data (v20 CCL structure)
        if (patient.perfusion && Array.isArray(patient.perfusion) && patient.perfusion.length > 0) {
            // Get most recent assessment (first in array)
            const latestPerfusion = patient.perfusion[0];

            if (latestPerfusion && latestPerfusion.eventId) {
                this._logDebug(`Found perfusion PowerForm assessment: Event ID ${latestPerfusion.eventId}`);

                // Return complete perfusion details
                return {
                    completed: true,
                    completedDateTime: latestPerfusion.eventEndDtTmDisp || null,
                    performedPrsnlName: latestPerfusion.performedPrsnlName || null,
                    performedPrsnlPosition: latestPerfusion.performedPrsnlPosition || null,
                    eventCdDisp: latestPerfusion.eventCdDisp || "QM Septic Shock Assessment",
                    resultVal: latestPerfusion.resultVal || "",
                    clinicalEventId: latestPerfusion.clinicalEventId || null,
                    eventId: latestPerfusion.eventId || null
                };
            }
        }

        // No perfusion assessment data found
        this._logDebug('No perfusion PowerForm data found');
        return defaultResponse;
    };

    PatientDataService.prototype.determineScreeningStatus = function(patient) {
        // Check if Screening status is already pre-computed (from mock data)
        if (patient.SEPSIS_SCREEN_ASSESSMENT) {
            this._logDebug(`Using pre-computed Screening Assessment: ${patient.SEPSIS_SCREEN_ASSESSMENT}`);
            return patient.SEPSIS_SCREEN_ASSESSMENT;
        }
        
        // REAL POWERFORM INTEGRATION - v06 CCL PowerForm assessment data
        // Process real PowerForm assessment data from v06 CCL
        
        // Check for PowerForm screen assessment data (v06 CCL structure)
        if (patient.screen && Array.isArray(patient.screen) && patient.screen.length > 0) {
            // Get most recent assessment (first in array)
            const latestAssessment = patient.screen[0];
            
            if (latestAssessment && latestAssessment.resultVal) {
                const assessmentText = latestAssessment.resultVal;
                this._logDebug(`Found PowerForm sepsis assessment: "${assessmentText}"`);
                
                // Map PowerForm responses to display values
                if (assessmentText.includes('ruled out')) {
                    return "Ruled Out";
                } else if (assessmentText.includes('Septic Shock') || assessmentText.includes('hypotension')) {
                    return "Septic Shock";
                } else if (assessmentText.includes('Severe Sepsis has been confirmed')) {
                    return "Severe Sepsis";
                } else if (assessmentText.includes('cannot determine')) {
                    return "Cannot Determine";
                } else {
                    // Unknown assessment type
                    this._logDebug(`Unknown PowerForm assessment: ${assessmentText}`);
                    return "Cannot Determine"; // Conservative default
                }
            }
        }
        
        // No PowerForm assessment data found - real v06 CCL implementation
        this._logDebug('No PowerForm assessment data found - no sepsis screening completed');
        return "--"; // No PowerForm assessment completed
    };

    /**
     * Determine Pressor tooltip details for Casey's dashboard requirements
     * Show pressor medications with administration times (like antibiotic format)
     */
    PatientDataService.prototype.determinePressorsDetails = function(patient) {
        this._logDebug('=== Determining Pressors Details ===');

        if (!patient || !patient.pressors || !Array.isArray(patient.pressors)) {
            return {
                status: 'Not Available',
                details: 'No pressor data available',
                medications: []
            };
        }

        const activePressors = patient.pressors.filter(pressor =>
            pressor.orderStatusDisp &&
            !["Discontinued", "Canceled", "Voided"].includes(pressor.orderStatusDisp)
        );

        if (activePressors.length === 0) {
            return {
                status: 'Not Ordered',
                details: 'No pressor medications ordered',
                medications: []
            };
        }

        const medications = activePressors.map(pressor => {
            const medInfo = {
                name: pressor.orderMnemonic,
                status: pressor.orderStatusDisp,
                orderPhase: pressor.powerplanPhase || 'All Sources',
                administrations: pressor.totalAdministrations || 0,
                firstAdmin: pressor.firstAdminDtTmDisp || 'Not administered'
            };

            // Add administration details if available
            if (pressor.administrations && pressor.administrations.length > 0) {
                medInfo.administrationDetails = pressor.administrations.map(admin => ({
                    time: admin.adminDtTmDisp,
                    dose: admin.adminDose,
                    unit: admin.adminDoseUnit,
                    route: admin.adminRoute,
                    site: admin.adminSite
                }));
            }

            return medInfo;
        });

        // Determine overall status
        const administeredCount = medications.filter(med => med.administrations > 0).length;
        const pendingCount = medications.filter(med => med.administrations === 0).length;

        let status;
        if (administeredCount > 0) {
            status = `${administeredCount} administered`;
            if (pendingCount > 0) {
                status += `, ${pendingCount} pending`;
            }
        } else {
            status = `${pendingCount} ordered (pending administration)`;
        }

        return {
            status: status,
            details: `${medications.length} pressor medication(s)`,
            medications: medications,
            totalPressors: medications.length,
            administeredPressors: administeredCount,
            pendingPressors: pendingCount
        };
    };

    // Expose to global scope
    window.PatientDataService = PatientDataService;

})(window);