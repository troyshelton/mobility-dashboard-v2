// Patient List MPage - Main Application Logic
(function(window) {
    'use strict';
    
    // Debug Configuration (SIMULATOR_CONFIG and USER_CONTEXT_CONFIG now in Config.js)
    const DEBUG_CONFIG = {
        enabled: true, // Default enabled until issues resolved
        logLevel: 'info' // 'error', 'warn', 'info', 'debug'
    };
    
    // Debug control functions moved to AdminCommands.js
    
    // Admin functions moved to AdminCommands.js
    // UI functions moved to VisualIndicators.js
    
    // Debug logging function
    function debugLog(message, level = 'info', ...args) {
        if (!DEBUG_CONFIG.enabled) return;
        
        const timestamp = new Date().toISOString();
        const prefix = `[PatientListApp-${level.toUpperCase()}] ${timestamp}:`;
        
        switch(level) {
            case 'error':
                console.error(prefix, message, ...args);
                break;
            case 'warn':
                console.warn(prefix, message, ...args);
                break;
            case 'debug':
                console.debug(prefix, message, ...args);
                break;
            default:
                console.log(prefix, message, ...args);
        }
    }

    /**
     * Filter: Current Patients (Issue #57)
     * Excludes patients with no bed assignment (roombed = '-')
     * Includes: ER beds, hallways, waiting room
     */
    function isCurrentPatient(patient) {
        const roomBed = patient.ROOM_BED;
        // Exclude single dash '-' (no location assigned)
        // Include: actual room numbers, "Waiting Room-", hallways, etc.
        return roomBed && roomBed !== '-' && roomBed.trim() !== '';
    }

    // REMOVED: meetsSepsisCriteria function (sepsis-specific logic removed for mobility dashboard)

    /**
     * Apply patient filters based on dropdown selection (Issue #57 - FirstNet style)
     */
    function applyPatientFilters(patients) {
        const filterSelect = document.getElementById('patient-filter-select');
        const filterValue = filterSelect ? filterSelect.value : 'current-sepsis';

        debugLog(`Filter selected: ${filterValue}`);

        let filtered = patients;
        let filterCurrentPatients = false;

        // Apply filters based on dropdown selection
        switch(filterValue) {
            case 'none':
                // No filtering
                break;
            case 'current':
                filtered = filtered.filter(isCurrentPatient);
                filterCurrentPatients = true;
                debugLog(`After Current Patients filter: ${filtered.length} patients`);
                break;
            // REMOVED: 'sepsis' and 'current-sepsis' cases (mobility dashboard)
        }

        // Update patient stats indicator (FirstNet style)
        updatePatientStats(patients, filtered, filterValue);

        return filtered;
    }

    /**
     * Update patient stats indicator
     * Format: WR: X  Total: Y
     * Stats are DYNAMIC based on what's displayed
     */
    function updatePatientStats(allPatients, filteredPatients, filterMode) {
        const indicator = document.getElementById('patient-stats-indicator');
        if (!indicator) return;

        // Calculate stats from FILTERED patients (what's actually displayed)
        const waitingRoomInFiltered = filteredPatients.filter(p => {
            const room = p.ROOM_BED;
            return room && room.toLowerCase().includes('waiting');
        }).length;

        // Total = count of filtered patients
        const totalCount = filteredPatients.length;

        // Use HTML with spans for visual separation
        const statsHTML = `
            <span class="stat-item">WR: ${waitingRoomInFiltered}</span>
            <span class="stat-item">Total: ${totalCount}</span>
        `;

        indicator.innerHTML = statsHTML;
        debugLog(`Stats updated: WR: ${waitingRoomInFiltered}  Total: ${totalCount} (Filter: ${filterMode})`);
    }

    // Version Information (Required per CLAUDE.md standards)
    // v23: Frontend version marker for cache verification
    window.FRONTEND_VERSION_CHECK = {
        version: 'v23-fluids-enhancement',
        timestamp: '2025-11-26T20:45:00Z',
        issue: '#75',
        loaded: new Date().toISOString()
    };
    console.log('%c🎯 FRONTEND VERSION CHECK', 'background: blue; color: white; font-size: 16px; padding: 4px;');
    console.log('%cVersion: v23-fluids-enhancement | Timestamp: 2025-11-26T20:45:00Z | Issue: #75', 'color: blue; font-weight: bold; font-size: 14px;');
    console.log('%cLoaded at: ' + new Date().toISOString(), 'color: blue; font-size: 12px;');
    console.log('%c═══════════════════════════════════════════════════════════', 'color: blue;');

    window.PROJECT_VERSION = {
        version: "v1.26.0-sepsis",
        buildDate: "2025-09-24",
        branch: "main",
        commit: "9ce5be6",
        repository: "https://github.com/troyshelton/sepsis-dashboard",
        repositoryName: "sepsis-dashboard",
        cclVersion: "v15",
        features: ["patient-list-selection", "simulator-mode", "handsontable-display", "eruda-debug", "ccl-integration", "service-architecture", "debug-flag-system", "powerplan-column", "lactate-column", "lactate-tooltips", "cerner-style-tooltips", "blood-culture-column", "antibiotic-column", "fluid-column", "pressor-detection", "timeout-optimization", "global-phase-filtering", "healthcare-order-icons", "alert-tooltips", "blob-data-extraction", "criteria-parsing", "volume-tracking", "administration-times", "perfusion-assessment", "demo-ready"]
    };
    
    // Global application state
    window.PatientListApp = {
        services: {
            userInfo: null,
            patientList: null,
            patientData: null
        },
        state: {
            currentListId: null,
            handsontableInstance: null
        },
        initialized: false,
        init: initializeApp, // Main entry point

        // Debug helper functions (call from console)
        getPatientData: function(patientName) {
            if (!this.state.handsontableInstance) {
                console.log('❌ No table data loaded');
                return null;
            }
            const data = this.state.handsontableInstance.getSourceData();
            if (patientName) {
                const patient = data.find(p => p.PATIENT_NAME && p.PATIENT_NAME.includes(patientName));
                console.log('📋 Patient Data:', patient);
                return patient;
            } else {
                console.log('📋 All Patient Data:', data);
                return data;
            }
        },
        getRawResponse: function() {
            console.log('📋 Last CCL Response stored in services');
            return {
                patientData: this.services.patientData,
                note: 'Check PatientListApp.services.patientData for last response'
            };
        },

        // Tippy.js utility functions (Issue #48 - Phase 2)
        createSepsisTooltip: createSepsisTooltip,
        buildStructuredTooltip: buildStructuredTooltip,
        buildActionTooltip: buildActionTooltip
    };

    /**
     * ============================================
     * Tippy.js Tooltip Utility Functions (Issue #48 - Phase 2)
     * ============================================
     */

    /**
     * Create standardized Sepsis Dashboard tooltip using Tippy.js
     * @param {HTMLElement} element - Element to attach tooltip to
     * @param {string} content - HTML content for tooltip
     * @param {object} options - Optional Tippy.js overrides
     * @returns {object|null} Tippy instance or null if tippy unavailable
     */
    function createSepsisTooltip(element, content, options = {}) {
        if (!element || typeof tippy === 'undefined') {
            debugLog('createSepsisTooltip: element or tippy not available', 'warn');
            return null;
        }

        return tippy(element, {
            content: content,
            onShow: function(instance) {
                // Hide all other tooltips to prevent overlap
                tippy.hideAll({ exclude: instance });
            },
            ...options // Allow per-tooltip overrides
        });
    }

    /**
     * Build structured tooltip HTML with label-value pairs
     * @param {object} data - Tooltip data fields
     * @returns {string} HTML string for tooltip
     */
    function buildStructuredTooltip(data) {
        let html = '<div class="tooltip-timing">';

        // Standard fields
        const fields = [
            { key: 'eventType', label: 'Event Type:' },
            { key: 'completedBy', label: 'Completed By:' },
            { key: 'position', label: 'Position:' },
            { key: 'completed', label: 'Completed:' },
            { key: 'orderStatus', label: 'Order Status:' },
            { key: 'phase', label: 'Phase:' }
        ];

        fields.forEach(field => {
            if (data[field.key]) {
                html += `
                    <div class="tooltip-timing-item">
                        <span class="tooltip-timing-label">${field.label}</span>
                        <span class="tooltip-timing-value">${data[field.key]}</span>
                    </div>
                `;
            }
        });

        // Action message (centered at bottom)
        if (data.actionMessage) {
            html += `
                <div class="tooltip-timing-item" style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #d1d5db; justify-content: center;">
                    <span style="font-style: italic; color: #6b7280; text-align: center; width: 100%;">${data.actionMessage}</span>
                </div>
            `;
        }

        html += '</div>';
        return html;
    }

    /**
     * Build simple action message tooltip
     * @param {string} message - Action message
     * @returns {string} HTML string for tooltip
     */
    function buildActionTooltip(message) {
        return `
            <div class="tooltip-timing">
                <div class="tooltip-timing-item" style="justify-content: center;">
                    <span style="font-style: italic; color: #6b7280; text-align: center; width: 100%;">${message}</span>
                </div>
            </div>
        `;
    }

    /**
     * Main application initialization function
     */
    async function initializeApp() {
        debugLog('Sepsis Dashboard Initialized');
        debugLog('📋 Version: ' + window.PROJECT_VERSION.version + ' | Branch: ' + window.PROJECT_VERSION.branch);
        debugLog('🚀 Features: ' + window.PROJECT_VERSION.features.join(', '));

        try {
            await initializeServices();
            window.PatientListApp.initialized = true;
            debugLog('Patient List MPage initialization complete');

            // Initialize empty table with prompt message (smooth UX from mobility-demo)
            initializeEmptyTable();

            // Debug: Check if anything is auto-loading patients
            debugLog('Initialization complete - no auto-loading should happen');
        } catch (error) {
            debugLog('Error during initialization: ' + error.message, 'error');
            displayInitializationError(error);
        }
    }
    
    /**
     * Initialize all services
     */
    async function initializeServices() {
        debugLog('Initializing services...');
        
        try {
            const app = window.PatientListApp;
            
            // Initialize services - they check global SIMULATOR_CONFIG internally
            app.services.userInfo = new UserInfoService(false); // Disable verbose logging
            app.services.patientList = new PatientListService(false); // Disable verbose logging
            app.services.patientData = new PatientDataService(false); // Disable verbose logging
            
            console.log('Services initialized successfully');
            
            // CRITICAL: Get user info first to obtain person_id before loading patient lists
            debugLog('Getting user information...');
            const userInfo = await app.services.userInfo.getUserEnvironmentInfo();
            debugLog('User info retrieved:', 'info', userInfo);
            
            // Extract real person_id from user info response (respiratory MPage pattern)
            // Handle both REC format and already-extracted format
            let actualUserId = null;
            if (userInfo) {
                if (userInfo.REC && userInfo.REC.USER_ID) {
                    actualUserId = userInfo.REC.USER_ID.toString();
                } else if (userInfo.USER_ID) {
                    actualUserId = userInfo.USER_ID.toString();
                } else if (userInfo.user_id) {
                    actualUserId = userInfo.user_id.toString();
                }
            }
            debugLog('User info structure:', 'debug', userInfo);
            debugLog('Extracted actual user ID: ' + actualUserId);
            
            // Recreate PatientListService with real person_id (respiratory MPage pattern)
            if (actualUserId) {
                debugLog('Recreating PatientListService with real person_id...');
                app.services.patientList = new PatientListService(DEBUG_CONFIG.enabled, actualUserId);
            }
            
            // Load initial data with real user context
            loadPatientLists();
            
            // Set up event handlers
            setupEventHandlers();
            
            app.initialized = true;
            console.log('Patient List MPage initialization complete');
            
        } catch (error) {
            console.error('Error during service initialization:', error);
            displayInitializationError(error);
        }
    }
    
    /**
     * Load patient lists into dropdown
     */
    async function loadPatientLists() {
        try {
            const patientLists = await window.PatientListApp.services.patientList.getPatientLists();
            const dropdown = document.getElementById('patient-list-select');
            
            if (!dropdown) {
                console.error('Patient list dropdown not found');
                return;
            }
            
            // Clear existing options except the first one
            while (dropdown.children.length > 1) {
                dropdown.removeChild(dropdown.lastChild);
            }
            
            // Add patient list options
            if (patientLists && patientLists.length > 0) {
                patientLists.forEach(list => {
                    const option = document.createElement('option');
                    option.value = list.id;
                    option.textContent = list.name;
                    dropdown.appendChild(option);
                });
                console.log(`Loaded ${patientLists.length} patient lists`);
            } else {
                console.warn('No patient lists found');
                const option = document.createElement('option');
                option.value = '';
                option.textContent = 'No patient lists available';
                option.disabled = true;
                dropdown.appendChild(option);
            }
        } catch (error) {
            console.error('Error loading patient lists:', error);
            displayError('Failed to load patient lists: ' + error.message);
        }
    }
    
    /**
     * Set up event handlers
     */
    function setupEventHandlers() {
        const dropdown = document.getElementById('patient-list-select');
        if (dropdown) {
            dropdown.addEventListener('change', handlePatientListChange);
        }
        
        // Removed auto-focus to prevent triggering change events
    }
    
    
    /**
     * Initialize patient table with Handsontable
     */
    function initializePatientTable(data) {
        const container = document.getElementById('patient-table-container');
        const app = window.PatientListApp;
        
        if (!container) {
            console.error('Patient table container not found');
            return;
        }

        // Get or create table div (preserve existing to avoid disappearing table)
        let tableDiv = document.getElementById('patient-table');
        if (!tableDiv) {
            // First time: Clear container and create table div
            console.log('Creating table div for first time...');
            container.innerHTML = '';
            tableDiv = document.createElement('div');
            tableDiv.id = 'patient-table';
            container.appendChild(tableDiv);
        } else {
            console.log('Reusing existing table div...');
        }

        // Helper Functions for Conditional Bundle Display (Issue #31, Task 7.1-7.2)
        // These determine when to show bundle icons vs blank cells

        /**
         * Check if patient has Severe Sepsis indication (3-hour bundle criteria)
         * @param {Object} patient - Patient data object
         * @returns {boolean} - True if patient has severe sepsis indication
         */
        function hasSevereSepsisIndication(patient) {
            if (!patient) {
                console.log('🔍 hasSevereSepsisIndication: patient is null/undefined');
                return false;
            }

            console.log('🔍 Checking sepsis indication for:', patient.PATIENT_NAME);
            console.log('🔍 Alert:', patient.ALERT_TYPE);
            console.log('🔍 Screening:', patient.SEPSIS_SCREEN_ASSESSMENT);
            console.log('🔍 PowerPlan:', patient.POWERPLAN_ORDERED);
            console.log('🔍 timeZero:', patient.timeZero);

            // Check 1: Alert fired (Severe Sepsis OR Septic Shock)
            // Note: Septic Shock includes Severe Sepsis requirements
            if (patient.ALERT_TYPE &&
                (patient.ALERT_TYPE.includes('Severe Sepsis') ||
                 patient.ALERT_TYPE.includes('Sepsis') ||
                 patient.ALERT_TYPE.includes('Septic Shock'))) {
                console.log('✅ Has sepsis indication: ALERT');
                return true;
            }

            // Check 2: Diagnosis documented (timeZero array)
            if (patient.timeZero && Array.isArray(patient.timeZero) && patient.timeZero.length > 0) {
                for (let i = 0; i < patient.timeZero.length; i++) {
                    const diagDisplay = patient.timeZero[i].diagDisplay || '';
                    console.log('🔍 Checking diagnosis:', diagDisplay);
                    if (diagDisplay.toLowerCase().includes('severe sepsis') ||
                        diagDisplay.toLowerCase().includes('septic shock')) {
                        console.log('✅ Has sepsis indication: DIAGNOSIS');
                        return true;
                    }
                }
            }

            // Check 3: Screening PowerForm confirms Severe Sepsis or Septic Shock
            if (patient.SEPSIS_SCREEN_ASSESSMENT &&
                (patient.SEPSIS_SCREEN_ASSESSMENT.includes('Severe Sepsis') ||
                 patient.SEPSIS_SCREEN_ASSESSMENT.includes('Septic Shock'))) {
                console.log('✅ Has sepsis indication: SCREENING');
                return true;
            }

            // Check 4: Sepsis PowerPlan ordered/initiated
            if (patient.POWERPLAN_ORDERED === 'Y' || patient.POWERPLAN_ORDERED === 'Pend') {
                console.log('✅ Has sepsis indication: POWERPLAN');
                return true;
            }

            console.log('❌ NO sepsis indication found');
            return false;
        }

        /**
         * Check if patient has Septic Shock indication (6-hour bundle criteria)
         * Clinical: Septic Shock = Severe Sepsis + (Hypotension OR Lactate ≥4.0)
         * @param {Object} patient - Patient data object
         * @returns {boolean} - True if patient has septic shock indication
         */
        function hasSepticShockIndication(patient) {
            if (!patient) return false;

            // Check 1: Septic Shock alert fired
            if (patient.ALERT_TYPE && patient.ALERT_TYPE.includes('Septic Shock')) {
                return true;
            }

            // Check 2: Septic Shock diagnosis documented (timeZero array)
            if (patient.timeZero && Array.isArray(patient.timeZero) && patient.timeZero.length > 0) {
                for (let i = 0; i < patient.timeZero.length; i++) {
                    const diagDisplay = patient.timeZero[i].diagDisplay || '';
                    if (diagDisplay.toLowerCase().includes('septic shock')) {
                        return true;
                    }
                }
            }

            // Check 3: Screening PowerForm confirms Septic Shock
            if (patient.SEPSIS_SCREEN_ASSESSMENT &&
                patient.SEPSIS_SCREEN_ASSESSMENT.includes('Septic Shock')) {
                return true;
            }

            // Check 4: Severe Sepsis + Critical Indicators
            // Septic shock = Severe sepsis + (critical lactate OR persistent hypotension)
            if (hasSevereSepsisIndication(patient)) {
                // Critical lactate (≥4.0)
                const hasCriticalLactate = patient.LACTATE_RESULT &&
                                          parseFloat(patient.LACTATE_RESULT) >= 4.0;

                // Persistent hypotension (MAP <65 mmHg)
                // TODO: Implement when MAP data available from Cerner
                const hasPersistentHypotension = false; // Placeholder

                if (hasCriticalLactate || hasPersistentHypotension) {
                    return true;
                }
            }

            return false;
        }

        // Custom renderer for PowerPlan healthcare order status icons
        // Removed statusRenderer and acuityRenderer - columns no longer displayed

        function powerplanRenderer(instance, td, row, col, prop, value, cellProperties) {
            // Conditional Bundle Display (Issue #31, Task 7.3)
            // Only show icons if patient has severe sepsis indication
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));

            if (!hasSevereSepsisIndication(sourceData)) {
                td.innerHTML = '';  // Blank cell for non-sepsis patients
                return td;
            }

            let htmlContent = '';

            // Get alert status for PowerPlan Quick Launch conditional (Issue #29)
            const hasAlert = sourceData?.ALERT_TYPE && sourceData.ALERT_TYPE !== '' && sourceData.ALERT_TYPE !== '--';

            // HEALTHCARE ORDER STATUS ICONS - Current implementation (2025-09-09)
            // Based on Healthcare Order Status Icons Technical Specification v3
            // Visual progression: Empty → Half-filled → Filled with checkmark
            // ENHANCED (2025-10-19): Alert-based conditional for PowerPlan Quick Launch
            switch (value) {
                case 'Y':
                    // PowerPlan initiated/completed - Green filled circle with white checkmark (NOT clickable - Issue #48)
                    htmlContent = '<div class="progress-completed" aria-label="PowerPlan initiated" data-powerplan-completed="true">✓</div>';
                    break;
                case 'Pend':
                    // PowerPlan planned/pending - Half-filled circle with yellow gradient
                    htmlContent = '<div class="progress-pending" aria-label="PowerPlan pending"></div>';
                    break;
                case 'N':
                    // ALERT CONDITIONAL LOGIC (PowerPlan Quick Launch POC - Issue #29)
                    // If alert exists AND PowerPlan not ordered → show clickable empty circle
                    if (hasAlert) {
                        // Clickable empty circle - launches PowerPlan ordering dialog
                        htmlContent = '<div class="progress-not-started clickable-action" aria-label="Click to order PowerPlan" data-action="order-powerplan"></div>';
                    } else {
                        // No alert - regular non-clickable empty circle
                        htmlContent = '<div class="progress-not-started" aria-label="PowerPlan not ordered"></div>';
                    }
                    break;
                default:
                    // No data available
                    htmlContent = '<div style="text-align: center; color: #9ca3af;">--</div>';
            }
            
            /* STATUS COLUMN CONSISTENT ICONS - Backup Option #1 (2025-09-09)
            // Matches Status column visual pattern for table consistency
            switch (value) {
                case 'Y':
                    icon = '<i class="fas fa-check-circle"></i>'; // Green check-circle (like Status "Stable")
                    textColor = '#16a34a'; // Green - PowerPlan active/initiated
                    fontWeight = 'bold';
                    break;
                case 'Pend':
                    icon = '<i class="fas fa-clock"></i>'; // Gold yellow clock - PowerPlan scheduled/pending
                    textColor = '#fbbf24'; // Gold Yellow - Waiting/planned
                    fontWeight = 'normal';
                    break;
                case 'N':
                    icon = '<i class="fas fa-plus-circle"></i>'; // Red plus-circle - PowerPlan needs to be added
                    textColor = '#dc2626'; // Red - Action required
                    fontWeight = 'bold';
                    break;
            }
            */
            
            /* TRAFFIC LIGHT CIRCLES - Backup Option #2 (2025-09-09)
            switch (value) {
                case 'Y':
                    icon = '<i class="fas fa-circle"></i>'; // Traffic light green
                    textColor = '#16a34a';
                    fontWeight = 'bold';
                    break;
                case 'N':
                    icon = '<i class="fas fa-circle"></i>'; // Traffic light red
                    textColor = '#dc2626';
                    fontWeight = 'bold';
                    break;
                case 'Pend':
                    icon = '<i class="fas fa-circle"></i>'; // Traffic light gold yellow
                    textColor = '#fbbf24';
                    fontWeight = 'normal';
                    break;
            }
            */
            
            /* ORIGINAL ICONS - Backup Option #3 (Initial implementation)
            switch (value) {
                case 'Y':
                    icon = '<i class="fas fa-check"></i>';      // Green checkmark
                    textColor = '#16a34a';
                    fontWeight = 'bold';
                    break;
                case 'N':
                    icon = '<i class="fas fa-times"></i>';      // Red X
                    textColor = '#dc2626';
                    fontWeight = 'bold';
                    break;
                case 'Pend':
                    icon = '<i class="fas fa-hourglass-half"></i>';  // Orange hourglass
                    textColor = '#f59e0b';  // Original orange
                    fontWeight = 'normal';
                    break;
            }
            */

            td.innerHTML = htmlContent;

            console.log('💼 PowerPlan renderer - value:', value, 'htmlContent:', htmlContent);

            // Add Tippy tooltips to PowerPlan elements (Issue #48)
            const powerplanCircle = td.querySelector('[data-action="order-powerplan"]');
            console.log('💼 PowerPlan empty circle found:', !!powerplanCircle);
            if (powerplanCircle) {
                const powerplanTooltip = buildActionTooltip('Click to order ED Sepsis PowerPlan');
                createSepsisTooltip(powerplanCircle, powerplanTooltip);
            }

            // Add tooltip to PowerPlan completed checkmark (Issue #48)
            const powerplanCompleted = td.querySelector('[data-powerplan-completed="true"]');
            console.log('💼 PowerPlan completed found:', !!powerplanCompleted, 'td.innerHTML:', td.innerHTML);
            if (powerplanCompleted) {
                const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));
                const powerplanDetails = sourceData?.POWERPLAN_DETAILS || {};
                const powerplans = sourceData?.powerplans || [];

                if (powerplans.length > 0) {
                    const pp = powerplans[0];
                    // Find the CAREPLAN phase (main PowerPlan, not subphases)
                    const careplanPhase = pp.phase?.find(p => p.pPhaseType === 'CAREPLAN') || pp.phase?.[0] || {};

                    // Custom tooltip for PowerPlan (user requested fields)
                    let tooltipHTML = '<div class="tooltip-timing">';

                    if (pp.ppPowerplanName) {
                        tooltipHTML += `<div class="tooltip-timing-item">
                            <span class="tooltip-timing-label">PowerPlan:</span>
                            <span class="tooltip-timing-value">${pp.ppPowerplanName}</span>
                        </div>`;
                    }

                    if (careplanPhase.pStatus) {
                        tooltipHTML += `<div class="tooltip-timing-item">
                            <span class="tooltip-timing-label">Order Status:</span>
                            <span class="tooltip-timing-value">${careplanPhase.pStatus}</span>
                        </div>`;
                    }

                    if (careplanPhase.pPhaseId) {
                        tooltipHTML += `<div class="tooltip-timing-item">
                            <span class="tooltip-timing-label">Pathway ID:</span>
                            <span class="tooltip-timing-value">${careplanPhase.pPhaseId}</span>
                        </div>`;
                    }

                    tooltipHTML += '</div>';

                    createSepsisTooltip(powerplanCompleted, tooltipHTML);
                } else {
                    // Fallback if no powerplan data
                    const fallbackTooltip = buildActionTooltip('ED Sepsis PowerPlan ordered');
                    createSepsisTooltip(powerplanCompleted, fallbackTooltip);
                }
            }

            td.style.textAlign = 'center';
            td.style.verticalAlign = 'middle';
            return td;
        }

        function screenAssessmentRenderer(instance, td, row, col, prop, value, cellProperties) {

            // Get source data
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));
            const screeningNotDone = !value || value === '--' || value === '';

            // Check if patient has alert (screening indicated)
            const alertData = sourceData?.ALERT_TYPE || sourceData?.ALERT_DETAILS?.hasAlert;
            const hasAlert = alertData && alertData !== '--' && alertData !== '' && alertData !== false;

            console.log('📋 SCREEN RENDERER - Patient:', sourceData?.PATIENT_NAME, 'Screening Value:', value, 'Has Alert:', hasAlert);

            // If alert exists but screening NOT done, show clickable empty circle (Issue #41)
            if (hasAlert && screeningNotDone) {
                console.log('📋 SHOWING CLICKABLE EMPTY CIRCLE - Alert exists, screening not done');
                const clickableCircle = document.createElement('div');
                clickableCircle.className = 'progress-not-started clickable-action';
                clickableCircle.setAttribute('aria-label', 'Click to complete sepsis screening');
                // Removed title - using Tippy.js (Issue #48)

                // Add click handler - Launch Sepsis Screening PowerForm
                clickableCircle.addEventListener('click', function() {
                    console.log('📋 SCREEN CLICK - Patient:', sourceData?.PATIENT_NAME);
                    const personId = sourceData?.PERSON_ID;
                    const encntrId = sourceData?.ENCNTR_ID;

                    if (personId && encntrId && window.PowerFormLauncher) {
                        window.PowerFormLauncher.launchSepsisScreening(personId, encntrId);
                    } else {
                        console.error('📋 Missing patient IDs or PowerFormLauncher not loaded');
                    }
                });

                // Attach Tippy.js tooltip (Issue #48 - Phase 3.2 fix)
                const emptyScreenTooltip = buildActionTooltip('Click to open Sepsis Screening PowerForm');
                createSepsisTooltip(clickableCircle, emptyScreenTooltip);

                td.innerHTML = '';
                td.appendChild(clickableCircle);
                td.style.textAlign = 'center';
                td.style.verticalAlign = 'middle';
                return td;
            }

            // If no alert and no screening, show blank cell (screening not indicated)
            if (!hasAlert && screeningNotDone) {
                td.innerHTML = '';  // Blank cell - no alert, screening not indicated
                td.style.textAlign = 'center';
                td.style.verticalAlign = 'middle';
                return td;
            }

            // NEW (Issue #41): Color-coded icons for screening results
            // Provider's screening assessment is the definitive clinical decision
            const screenDetails = sourceData?.SCREEN_DETAILS || { assessment: value, completedDateTime: null, eventId: null, clinicalEventId: null, eventCdDisp: null, resultVal: null };

            let iconClass = '';
            let iconText = '';
            let tooltipLabel = '';
            let ariaLabel = '';

            // Map screening values to color-coded icons (Issue #41)
            // Based on real CERT data patterns from screen.eventTag field
            // IMPORTANT: Check "cannot determine" and "ruled out" FIRST before checking "severe sepsis"
            const assessmentLower = (screenDetails.assessment || '').toLowerCase();
            console.log('📋 SCREENING COLOR LOGIC - Patient:', sourceData?.PATIENT_NAME, 'Assessment:', screenDetails.assessment, 'Lower:', assessmentLower);

            if (assessmentLower.includes('cannot determine') || assessmentLower.includes('indeterminate')) {
                // YELLOW: Indeterminate/Cannot determine (? mark) - CHECK FIRST
                iconClass = 'screening-indeterminate clickable-action';
                iconText = '?';
                tooltipLabel = 'Sepsis Screening: Indeterminate';
                ariaLabel = 'Sepsis screening indeterminate - click to view details';
            } else if (assessmentLower.includes('ruled out') || assessmentLower.includes('no evidence')) {
                // GREEN: Ruled out (empty circle) - CHECK SECOND
                iconClass = 'screening-ruled-out clickable-action';
                iconText = '';
                tooltipLabel = 'Sepsis Screening: Ruled Out';
                ariaLabel = 'Sepsis screening ruled out - click to view details';
            } else if (assessmentLower.includes('septic shock')) {
                // RED: Septic Shock (!! - double exclamation)
                iconClass = 'screening-positive clickable-action';
                iconText = '!!';
                tooltipLabel = 'Sepsis Screening: Septic Shock';
                ariaLabel = 'Septic shock confirmed - click to view details';
            } else if (assessmentLower.includes('confirmed') || assessmentLower.includes('severe sepsis')) {
                // RED: Severe Sepsis (! - single exclamation)
                iconClass = 'screening-positive clickable-action';
                iconText = '!';
                tooltipLabel = 'Sepsis Screening: Severe Sepsis';
                ariaLabel = 'Severe sepsis confirmed - click to view details';
            } else {
                // DEFAULT: YELLOW for any unexpected values
                iconClass = 'screening-indeterminate clickable-action';
                iconText = '?';
                tooltipLabel = 'Sepsis Screening: Indeterminate';
                ariaLabel = 'Sepsis screening indeterminate - click to view details';
            }

            // Debug what screen data we're actually getting
            console.log('📋 SCREEN TOOLTIP DATA:', screenDetails);

            // Build screening tooltip using Tippy.js (Issue #48 - Phase 3.2)
            // Custom builder for screening (has assessment and resultVal fields)
            let tooltipHTML = '<div class="tooltip-timing">';

            if (screenDetails.assessment !== "--") {
                tooltipHTML += `<div class="tooltip-timing-item">
                    <span class="tooltip-timing-label">Assessment:</span>
                    <span class="tooltip-timing-value">${screenDetails.assessment}</span>
                </div>`;
            }

            if (screenDetails.resultVal && screenDetails.resultVal !== screenDetails.assessment) {
                tooltipHTML += `<div class="tooltip-timing-item">
                    <span class="tooltip-timing-label">Full Text:</span>
                    <span class="tooltip-timing-value">${screenDetails.resultVal}</span>
                </div>`;
            }

            if (screenDetails.completedDateTime) {
                tooltipHTML += `<div class="tooltip-timing-item">
                    <span class="tooltip-timing-label">Completed:</span>
                    <span class="tooltip-timing-value">${screenDetails.completedDateTime}</span>
                </div>`;
            }

            if (screenDetails.eventCdDisp) {
                tooltipHTML += `<div class="tooltip-timing-item">
                    <span class="tooltip-timing-label">Event Type:</span>
                    <span class="tooltip-timing-value">${screenDetails.eventCdDisp}</span>
                </div>`;
            }

            if (screenDetails.performedPrsnlName) {
                tooltipHTML += `<div class="tooltip-timing-item">
                    <span class="tooltip-timing-label">Completed By:</span>
                    <span class="tooltip-timing-value">${screenDetails.performedPrsnlName}</span>
                </div>`;
            }

            if (screenDetails.performedPrsnlPosition) {
                tooltipHTML += `<div class="tooltip-timing-item">
                    <span class="tooltip-timing-label">Position:</span>
                    <span class="tooltip-timing-value">${screenDetails.performedPrsnlPosition}</span>
                </div>`;
            }

            // Add action message (Issue #48 - Phase 3.2 fix - match Perfusion pattern)
            tooltipHTML += `
                <div class="tooltip-timing-item" style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #d1d5db; justify-content: center;">
                    <span style="font-style: italic; color: #6b7280; text-align: center; width: 100%;">Click to open Sepsis Screening PowerForm</span>
                </div>
            `;

            tooltipHTML += '</div>';

            // NEW (Issue #41): Create color-coded icon with tooltip
            const iconDiv = document.createElement('div');
            iconDiv.className = iconClass;
            iconDiv.setAttribute('aria-label', ariaLabel);
            // Removed title attribute - using Tippy.js instead (Issue #48)
            iconDiv.textContent = iconText; // Display !, !!, ?, or empty for ruled out

            // Add click handler - Launch Sepsis Screening PowerForm (Issue #41)
            iconDiv.addEventListener('click', function() {
                console.log('📋 SCREEN ICON CLICK - Patient:', sourceData?.PATIENT_NAME, 'Status:', tooltipLabel);
                const personId = sourceData?.PERSON_ID;
                const encntrId = sourceData?.ENCNTR_ID;

                if (personId && encntrId && window.PowerFormLauncher) {
                    window.PowerFormLauncher.launchSepsisScreening(personId, encntrId);
                } else {
                    console.error('📋 Missing patient IDs or PowerFormLauncher not loaded');
                }
            });

            // Attach Tippy.js tooltip to icon (Issue #48 - Phase 3.2)
            createSepsisTooltip(iconDiv, tooltipHTML);

            // Clear existing content and add icon
            td.innerHTML = '';
            td.appendChild(iconDiv);
            td.style.textAlign = 'center'; // Center the icon
            td.style.verticalAlign = 'middle';
            return td;
        }

        function antibioticsOrderRenderer(instance, td, row, col, prop, value, cellProperties) {
            // Conditional Bundle Display (Issue #31, Task 7.6)
            // Only show icons if patient has severe sepsis indication
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));

            if (!hasSevereSepsisIndication(sourceData)) {
                td.innerHTML = '';  // Blank cell for non-sepsis patients
                return td;
            }

            // IMPLEMENTATION NOTE: Uses only existing PowerPlan antibiotic order data
            // Future: Will add administration times when available from Cerner MAR data
            // Framework ready for enhancement when real administration data is accessible
            const antibioticDetails = sourceData?.ANTIBIOTICS_DETAILS || { status: value, antibiotics: [], phase: null };

            // Check for alert to determine if clickable (Issue #55 - same pattern as Fluids)
            const alertData = sourceData?.ALERT_TYPE || sourceData?.ALERT_DETAILS?.hasAlert;
            const hasAlert = alertData && alertData !== '--' && alertData !== '' && alertData !== false;

            // Create tooltip content based on available order data
            let tooltipContent = '<div class="tooltip-timing">';

            // Overall status (improved alignment)
            tooltipContent += `
                <div class="tooltip-timing-item" style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                    <span class="tooltip-timing-label" style="font-weight: bold; margin-right: 8px;">Status:</span>
                    <span class="tooltip-timing-value" style="text-align: right;">${antibioticDetails.overallStatus || 'Unknown'}</span>
                </div>
            `;

            // PowerPlan phase information (improved alignment)
            if (antibioticDetails.phase) {
                tooltipContent += `
                    <div class="tooltip-timing-item" style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                        <span class="tooltip-timing-label" style="font-weight: bold; margin-right: 8px;">Phase:</span>
                        <span class="tooltip-timing-value" style="text-align: right; font-size: 11px;">${antibioticDetails.phase}</span>
                    </div>
                `;
            }

            // Antibiotic details with enhanced formatting
            if (antibioticDetails.antibiotics && antibioticDetails.antibiotics.length > 0) {
                tooltipContent += `
                    <div class="tooltip-timing-item" style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #ddd;">
                        <div style="font-weight: bold; margin-bottom: 4px;">Antibiotics:</div>
                    </div>
                `;
                antibioticDetails.antibiotics.forEach(antibiotic => {
                    // Handle both v13 enhanced and legacy data structures
                    const antibioticName = antibiotic.orderMnemonic || antibiotic.name || 'Unknown';
                    const primaryName = antibiotic.primaryMnemonic || '';  // v21: Standardized name
                    const orderId = antibiotic.orderId || 0;  // v21: For debugging
                    const antibioticStatus = antibiotic.orderStatus || antibiotic.status || 'Unknown';
                    const adminTime = antibiotic.firstAdminTime && !antibiotic.firstAdminTime.includes('Not administered') ?
                                    ` - Admin: ${antibiotic.firstAdminTime}` : '';

                    // v21: Show primary mnemonic only if different from order mnemonic
                    const primaryDisplay = (primaryName && primaryName !== antibioticName) ?
                                         `<br><span style="margin-left: 12px; color: #666; font-size: 10px; font-style: italic;">(Primary: ${primaryName})</span>` : '';

                    // v21: Show order ID for debugging (if valid)
                    const orderIdDisplay = (orderId > 0) ?
                                         `<br><span style="margin-left: 12px; color: #999; font-size: 10px;"><em>Order ID: ${orderId}</em></span>` : '';

                    tooltipContent += `
                        <div style="margin-bottom: 6px; font-size: 11px; line-height: 1.3;">
                            <span style="color: #333;">• ${antibioticName}</span>${primaryDisplay}<br>
                            <span style="margin-left: 12px; color: #6b7280; font-size: 10px;">(${antibioticStatus})${adminTime}</span>${orderIdDisplay}
                        </div>
                    `;
                });
            }

            tooltipContent += '</div>';

            // Use same healthcare icons as powerplanRenderer but wrapped in tooltip container
            let iconHtml = '';
            let isClickable = false;

            switch (antibioticDetails.status) {
                case 'Y':
                    iconHtml = '<div class="progress-completed" aria-label="Antibiotics ordered">✓</div>';
                    break;
                case 'Pend':
                    iconHtml = '<div class="progress-pending" aria-label="Antibiotics pending"></div>';
                    break;
                case 'N':
                    // Issue #55: If alert exists, make clickable to launch abbreviated order set (same as Fluids)
                    if (hasAlert) {
                        iconHtml = '<div class="progress-not-started clickable-action" aria-label="Click to order abbreviated sepsis PowerPlan" data-action="order-abbreviated-sepsis"></div>';
                        isClickable = true;
                    } else {
                        // No alert - regular non-clickable empty circle
                        iconHtml = '<div class="progress-not-started" aria-label="Antibiotics not ordered"></div>';
                    }
                    break;
                default:
                    iconHtml = '<div style="text-align: center; color: #9ca3af;">--</div>';
            }

            // Create container div
            const containerDiv = document.createElement('div');
            containerDiv.innerHTML = iconHtml;

            // Issue #55: Add click handler for abbreviated order set launcher (same as Fluids)
            if (isClickable) {
                const clickableCircle = containerDiv.querySelector('[data-action="order-abbreviated-sepsis"]');
                if (clickableCircle) {
                    clickableCircle.addEventListener('click', async function(e) {
                        e.stopPropagation();
                        console.log('💊 ANTIBIOTICS CLICK - Launching abbreviated order set for:', sourceData?.PATIENT_NAME);

                        const personId = sourceData?.PERSON_ID;
                        const encntrId = sourceData?.ENCNTR_ID;
                        const patientName = sourceData?.PATIENT_NAME;

                        if (personId && encntrId && window.PowerPlanLauncher) {
                            try {
                                const launcher = new window.PowerPlanLauncher();
                                await launcher.launchAbbreviatedSepsisOrders(personId, encntrId, patientName);
                            } catch (error) {
                                console.error('💊 Failed to launch abbreviated order set:', error);
                                alert('Failed to launch ED Severe Sepsis Resuscitation/Antibiotics order set. Please try again or contact support.');
                            }
                        } else {
                            console.error('💊 Missing patient IDs or PowerPlanLauncher not loaded');
                        }
                    });
                }
            }

            // Show tooltip based on status (Issue #48, Issue #55)
            if (antibioticDetails.status !== 'N') {
                // Y or Pend - show full antibiotic data tooltip
                createSepsisTooltip(containerDiv, tooltipContent);
            } else if (isClickable) {
                // N with alert - show action message for clickable circle (Issue #55)
                const clickTooltip = buildActionTooltip('Click to order abbreviated Severe Sepsis PowerPlan');
                createSepsisTooltip(containerDiv, clickTooltip);
            }
            // else: N without alert - no tooltip (not clickable, self-explanatory)

            // Clear existing content and add new container
            td.innerHTML = '';
            td.appendChild(containerDiv);
            td.style.textAlign = 'center';
            td.style.verticalAlign = 'middle';
            return td;
        }

        function bloodCulturesRenderer(instance, td, row, col, prop, value, cellProperties) {
            // Conditional Bundle Display (Issue #31, Task 7.5)
            // Only show icons if patient has severe sepsis indication
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));

            if (!hasSevereSepsisIndication(sourceData)) {
                td.innerHTML = '';  // Blank cell for non-sepsis patients
                return td;
            }

            // REAL CERNER DATA: Blood culture information from actual PowerPlan structure
            // Shows first completed/collected set with Order ID to differentiate two sets
            const culturesDetails = sourceData?.BLOOD_CULTURES_DETAILS || { status: value, firstSetOrderTime: null, firstSetCollectionTime: null };

            // Debug blood culture data
            console.log('🩸 BLOOD CULTURES TOOLTIP DATA:', culturesDetails);
            console.log('🩸 bloodCultures array:', culturesDetails.bloodCultures);

            // Create tooltip content showing ALL blood culture sets with complete timing (v18)
            let tooltipContent = '<div class="tooltip-timing">';

            // Total sets count (no ambiguous "Status" - timeline shows progression for each set)
            if (culturesDetails.totalSets) {
                tooltipContent += `
                    <div class="tooltip-timing-item" style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                        <span class="tooltip-timing-label" style="font-weight: bold; margin-right: 8px;">Sets Ordered:</span>
                        <span class="tooltip-timing-value" style="text-align: right;">${culturesDetails.totalSets}</span>
                    </div>
                `;
            }

            // Show ALL blood culture sets with complete timing (v18 enhancement - Casey's requirement)
            if (culturesDetails.bloodCultures && culturesDetails.bloodCultures.length > 0) {
                tooltipContent += `
                    <div class="tooltip-timing-item" style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #ddd;">
                        <div style="font-weight: bold; margin-bottom: 4px;">Blood Cultures:</div>
                    </div>
                `;

                culturesDetails.bloodCultures.forEach(bc => {
                    tooltipContent += `
                        <div style="margin-bottom: 8px;">
                            <div style="font-weight: bold; color: #333;">• Set ${bc.setNumber} (ID: ${bc.orderId})</div>
                    `;

                    // Show timing progression
                    if (bc.orderedTime) {
                        tooltipContent += `<div style="margin-left: 12px; font-size: 11px;">Ordered: ${bc.orderedTime}</div>`;
                    }
                    if (bc.dispatchedTime) {
                        tooltipContent += `<div style="margin-left: 12px; font-size: 11px;">Dispatched: ${bc.dispatchedTime}</div>`;
                    }
                    if (bc.collectedTime) {
                        tooltipContent += `<div style="margin-left: 12px; font-size: 11px; font-weight: bold; color: #059669;">Collected: ${bc.collectedTime}</div>`;
                    }
                    if (bc.inLabTime) {
                        tooltipContent += `<div style="margin-left: 12px; font-size: 11px;">In-Lab: ${bc.inLabTime}</div>`;
                    }
                    if (bc.prelimTime) {
                        tooltipContent += `<div style="margin-left: 12px; font-size: 11px;">Preliminary: ${bc.prelimTime}</div>`;
                    }
                    if (bc.completedTime) {
                        tooltipContent += `<div style="margin-left: 12px; font-size: 11px;">Completed: ${bc.completedTime}</div>`;
                    }

                    tooltipContent += `
                        </div>
                    `;
                });
            }

            tooltipContent += '</div>';

            // Use same healthcare icons as powerplanRenderer
            let iconHtml = '';
            const showTooltip = (culturesDetails.status !== 'N'); // Empty circle needs no tooltip

            switch (culturesDetails.status) {
                case 'Y':
                    iconHtml = '<div class="progress-completed" aria-label="Blood cultures collected">✓</div>';
                    break;
                case 'Pend':
                    iconHtml = '<div class="progress-pending" aria-label="Blood cultures pending"></div>';
                    break;
                case 'N':
                    iconHtml = '<div class="progress-not-started" aria-label="Blood cultures not ordered"></div>';
                    break;
                default:
                    iconHtml = '<div style="text-align: center; color: #9ca3af;">--</div>';
            }

            // Create container div
            const containerDiv = document.createElement('div');
            containerDiv.innerHTML = iconHtml;

            // Only show tooltip if there's actual data (Issue #48)
            if (showTooltip) {
                createSepsisTooltip(containerDiv, tooltipContent);
            }

            // Clear existing content and add new container
            td.innerHTML = '';
            td.appendChild(containerDiv);
            td.style.textAlign = 'center';
            td.style.verticalAlign = 'middle';
            return td;
        }

        function alertRenderer(instance, td, row, col, prop, value, cellProperties) {

            // Dashboard cleanup (Issue #31) - Show blank instead of "--" for cleaner look
            if (value === '--' || !value) {
                td.innerHTML = '';  // Blank cell - no alert
                td.style.textAlign = 'left';
                td.style.verticalAlign = 'middle';
                return td;
            }

            // Get source data to access alert details for tooltip
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));
            const alertDetails = sourceData?.ALERT_DETAILS || { hasAlert: false, alertTime: null, eventTag: null, criteriaList: [], rawCriteria: null };

            // Create tooltip content for alert criteria (Casey's Dr. Crawford requirement)
            let tooltipContent = '<div class="tooltip-timing">';

            // Alert basic information
            if (alertDetails.hasAlert && alertDetails.eventTag) {
                tooltipContent += `
                    <div class="tooltip-timing-item">
                        <span class="tooltip-timing-label">Alert:</span>
                        <span class="tooltip-timing-value">${alertDetails.eventTag}</span>
                    </div>
                `;
            }

            if (alertDetails.alertTime) {
                tooltipContent += `
                    <div class="tooltip-timing-item">
                        <span class="tooltip-timing-label">Fired:</span>
                        <span class="tooltip-timing-value">${alertDetails.alertTime}</span>
                    </div>
                `;
            }

            // Alert criteria (Dr. Crawford's specific request)
            if (alertDetails.criteriaList && alertDetails.criteriaList.length > 0) {
                tooltipContent += `
                    <div class="tooltip-timing-item" style="margin-top: 4px;">
                        <span class="tooltip-timing-label">Criteria Met (${alertDetails.criteriaList.length}):</span>
                        <span class="tooltip-timing-value"></span>
                    </div>
                    <ul class="alert-criteria-list">
                `;
                alertDetails.criteriaList.forEach(criteria => {
                    tooltipContent += `
                        <li class="alert-criteria-item">
                            <span class="alert-criteria-text">${criteria}</span>
                        </li>
                    `;
                });
                tooltipContent += '</ul>';
            } else if (alertDetails.hasAlert) {
                tooltipContent += `
                    <div class="tooltip-timing-item">
                        <span class="tooltip-timing-label">Criteria:</span>
                        <span class="tooltip-timing-value">No detailed criteria available</span>
                    </div>
                `;
            }

            tooltipContent += '</div>';

            // Create text element with Tippy.js tooltip (Issue #48 - Phase 3.3)
            const textDiv = document.createElement('div');
            textDiv.textContent = value;
            textDiv.style.display = 'block';

            createSepsisTooltip(textDiv, tooltipContent);

            td.innerHTML = '';
            td.appendChild(textDiv);
            td.style.textAlign = 'left'; // Left-aligned (v1.33.0)
            td.style.verticalAlign = 'middle';
            return td;
        }

        function timeZeroRenderer(instance, td, row, col, prop, value, cellProperties) {
            // Conditional Bundle Display (Issue #31) - Time Zero requires sepsis indication
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));

            if (!hasSevereSepsisIndication(sourceData)) {
                td.innerHTML = '';  // Blank cell - no Time Zero without sepsis indication
                return td;
            }

            // Get Time Zero source details for tooltip
            const timeZeroDetails = sourceData?.TIME_ZERO_DETAILS || {
                source: "None",
                sourceDisplay: "No source info",
                details: "No details available"
            };

            // Debug Time Zero data
            console.log('⏰ TIME ZERO TOOLTIP DATA:', timeZeroDetails);

            // Only create tooltip if we have valid source data
            if (value && value !== '--' && value !== 'Date NA' && timeZeroDetails.source !== 'None') {
                console.log('⏰ CREATING TOOLTIP for value:', value, 'source:', timeZeroDetails.source);

                // Create tooltip content (Casey's requirement) - Fixed alignment
                let tooltipContent = '<div class="tooltip-timing">';
                tooltipContent += `
                    <div class="tooltip-timing-item" style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                        <span class="tooltip-timing-label" style="font-weight: bold; margin-right: 8px;">Source:</span>
                        <span class="tooltip-timing-value" style="text-align: right;">${timeZeroDetails.sourceDisplay}</span>
                    </div>
                `;
                tooltipContent += `
                    <div class="tooltip-timing-item" style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                        <span class="tooltip-timing-label" style="font-weight: bold; margin-right: 8px;">Time:</span>
                        <span class="tooltip-timing-value" style="text-align: right;">${timeZeroDetails.timestamp}</span>
                    </div>
                `;
                // Show additional sources if multiple exist (clean formatting)
                if (timeZeroDetails.totalSources > 1) {
                    tooltipContent += `
                        <div class="tooltip-timing-item" style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #ddd;">
                            <div style="margin-bottom: 2px;">All Sources:</div>
                            <div style="font-size: 11px; color: #6b7280;">${timeZeroDetails.allSources}</div>
                        </div>
                    `;
                }
                tooltipContent += '</div>';

                // Create text div with Tippy.js tooltip (Issue #48 - Phase 3.4)
                const textDiv = document.createElement('div');
                textDiv.innerHTML = value || '';
                textDiv.style.display = 'block';

                createSepsisTooltip(textDiv, tooltipContent);

                td.innerHTML = '';
                td.appendChild(textDiv);
            } else {
                // Dashboard cleanup (Issue #31) - Show value or blank (no "--")
                td.innerHTML = (value && value !== 'Date NA') ? value : '';
            }

            td.style.textAlign = 'left'; // Left-aligned (v1.33.0)
            td.style.verticalAlign = 'middle';
            return td;
        }

        function fluidsRenderer(instance, td, row, col, prop, value, cellProperties) {
            // Conditional Bundle Display (Issue #31, Task 7.7)
            // Only show icons if patient has severe sepsis indication
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));

            if (!hasSevereSepsisIndication(sourceData)) {
                td.innerHTML = '';  // Blank cell for non-sepsis patients
                return td;
            }

            // Get fluid details for tooltip
            const fluidsDetails = sourceData?.FLUIDS_DETAILS || {
                status: value,
                fluids: [],
                totalVolume: 0,
                overallStatus: "Not Ordered"
            };

            // Check for alert to determine if clickable (Issue #37 - moved from Antibiotics per Casey)
            const alertData = sourceData?.ALERT_TYPE || sourceData?.ALERT_DETAILS?.hasAlert;
            const hasAlert = alertData && alertData !== '--' && alertData !== '' && alertData !== false;

            // FLUIDS LOGIC SIMPLIFIED (Casey's recommendation from 2025-10-22 meeting)
            // Show fluids for ALL severe sepsis patients (not just lactate ≥4.0)
            // Rationale: Most ED patients get fluids; captures Partial Fluid from PowerPlan
            // Note: 30 mL/kg requirement is for septic shock, but fluids often given for severe sepsis

            console.log('💧 FLUIDS - Showing for all severe sepsis patients (lactate check removed per Casey)');

            // Debug fluid data
            console.log('💧 FLUIDS TOOLTIP DATA:', fluidsDetails);

            // Create tooltip content with Casey's volume format
            let tooltipContent = '<div class="tooltip-timing">';

            // Overall status (improved alignment)
            tooltipContent += `
                <div class="tooltip-timing-item" style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                    <span class="tooltip-timing-label" style="font-weight: bold; margin-right: 8px;">Status:</span>
                    <span class="tooltip-timing-value" style="text-align: right;">${fluidsDetails.overallStatus || 'Unknown'}</span>
                </div>
            `;

            // Total volume (Casey's cumulative requirement)
            if (fluidsDetails.totalVolume > 0) {
                tooltipContent += `
                    <div class="tooltip-timing-item" style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                        <span class="tooltip-timing-label" style="font-weight: bold; margin-right: 8px;">Total Volume:</span>
                        <span class="tooltip-timing-value" style="text-align: right; font-weight: bold;">${fluidsDetails.totalVolume} mL</span>
                    </div>
                `;
            }

            // Fluid details with enhanced formatting (Casey's format)
            if (fluidsDetails.fluids && fluidsDetails.fluids.length > 0) {
                tooltipContent += `
                    <div class="tooltip-timing-item" style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #ddd;">
                        <div style="font-weight: bold; margin-bottom: 4px;">Fluids:</div>
                    </div>
                `;
                fluidsDetails.fluids.forEach(fluid => {
                    // Issue #33: Display ordered_as_mnemonic in parentheses after order mnemonic
                    const orderedAs = fluid.orderedAs || '';
                    const fluidName = fluid.orderMnemonic || 'Unknown';

                    // v23: Enhanced tooltip with primary mnemonic and order ID (same as antibiotics Issue #72)
                    const primaryName = fluid.primaryMnemonic || '';
                    const orderId = fluid.orderId || 0;

                    // Format: "Order Mnemonic (Ordered As)" if ordered_as exists
                    const fluidDisplay = orderedAs ? `${fluidName} (${orderedAs})` : fluidName;

                    // v23: Show primary mnemonic only if different from order mnemonic
                    const primaryDisplay = (primaryName && primaryName !== fluidName) ?
                        `<br><span style="margin-left: 12px; color: #666; font-size: 10px; font-style: italic;">(Primary: ${primaryName})</span>` : '';

                    // v23: Show order ID for debugging (if valid)
                    const orderIdDisplay = (orderId > 0) ?
                        `<br><span style="margin-left: 12px; color: #999; font-size: 10px;"><em>Order ID: ${orderId}</em></span>` : '';

                    const fluidStatus = fluid.orderStatus || 'Unknown';
                    const adminTime = fluid.firstAdminTime && !fluid.firstAdminTime.includes('Not administered') ?
                                    ` - ${fluid.totalVolume} mL at ${fluid.firstAdminTime}` : '';

                    // v23: Show multi-ingredient warning for troubleshooting
                    const multiIngredientWarning = fluid.multiIngredient ?
                        `<br><span style="margin-left: 12px; color: #ff6b00; font-size: 10px; font-weight: bold;">⚠️ EXCLUDED: Multi-ingredient (not counted in bundle)</span>` : '';

                    const fluidColor = fluid.multiIngredient ? '#999' : '#333';  // Gray out excluded fluids

                    tooltipContent += `
                        <div style="margin-bottom: 2px; font-size: 11px; line-height: 1.3;">
                            <span style="color: ${fluidColor};">• ${fluidDisplay}</span>${primaryDisplay}${multiIngredientWarning}<br>
                            <span style="margin-left: 12px; color: #6b7280; font-size: 10px;">(${fluidStatus})${adminTime}</span>${orderIdDisplay}
                        </div>
                    `;
                });
            }

            tooltipContent += '</div>';

            // Use same healthcare icons as other renderers
            let iconHtml = '';
            let isClickable = false;

            switch (fluidsDetails.status) {
                case 'Y':
                    iconHtml = '<div class="progress-completed" aria-label="Fluids administered">✓</div>';
                    break;
                case 'Pend':
                    iconHtml = '<div class="progress-pending" aria-label="Fluids ordered but not administered"></div>';
                    break;
                case 'N':
                    // Issue #37: If alert exists, make clickable to launch abbreviated order set (Casey: Fluids column)
                    if (hasAlert) {
                        iconHtml = '<div class="progress-not-started clickable-action" aria-label="Click to order abbreviated sepsis PowerPlan" data-action="order-abbreviated-sepsis"></div>';
                        isClickable = true;
                    } else {
                        // No alert - regular non-clickable empty circle
                        iconHtml = '<div class="progress-not-started" aria-label="No fluids ordered"></div>';
                    }
                    break;
                default:
                    iconHtml = '<div style="text-align: center; color: #9ca3af;">--</div>';
            }

            // Create container div with tooltip (using proven pattern)
            const containerDiv = document.createElement('div');
            containerDiv.className = 'tooltip-container';
            containerDiv.innerHTML = iconHtml;

            // Issue #37: Add click handler for abbreviated order set launcher (Casey: Fluids column)
            if (isClickable) {
                const clickableCircle = containerDiv.querySelector('[data-action="order-abbreviated-sepsis"]');
                if (clickableCircle) {
                    clickableCircle.addEventListener('click', async function(e) {
                        e.stopPropagation();
                        console.log('💧 FLUIDS CLICK - Launching abbreviated order set for:', sourceData?.PATIENT_NAME);

                        const personId = sourceData?.PERSON_ID;
                        const encntrId = sourceData?.ENCNTR_ID;
                        const patientName = sourceData?.PATIENT_NAME;

                        if (personId && encntrId && window.PowerPlanLauncher) {
                            try {
                                const launcher = new window.PowerPlanLauncher();
                                await launcher.launchAbbreviatedSepsisOrders(personId, encntrId, patientName);
                            } catch (error) {
                                console.error('💧 Failed to launch abbreviated order set:', error);
                                alert('Failed to launch ED Severe Sepsis Resuscitation/Antibiotics order set. Please try again or contact support.');
                            }
                        } else {
                            console.error('💧 Missing patient IDs or PowerPlanLauncher not loaded');
                        }
                    });
                }
            }

            // Attach Tippy.js tooltip (Issue #48 - Phase 3.5)
            // v23: Always show fluids tooltip if there are fluids (even if excluded) - for troubleshooting
            if (fluidsDetails.fluids && fluidsDetails.fluids.length > 0) {
                // Show full fluid data tooltip (including excluded fluids with warnings)
                createSepsisTooltip(containerDiv, tooltipContent);
            } else if (fluidsDetails.status !== 'N') {
                // Y or Pend but no fluids array - show status tooltip
                createSepsisTooltip(containerDiv, tooltipContent);
            } else if (isClickable) {
                // N with alert and NO fluids - show action message for clickable circle
                const clickTooltip = buildActionTooltip('Click to order abbreviated Severe Sepsis PowerPlan');
                createSepsisTooltip(containerDiv, clickTooltip);
            }
            // else: N without alert and no fluids - no tooltip (not clickable, self-explanatory)

            // Clear td and add container
            td.innerHTML = '';
            td.appendChild(containerDiv);
            td.style.textAlign = 'center';
            td.style.verticalAlign = 'middle';
            return td;
        }

        function pressorsRenderer(instance, td, row, col, prop, value, cellProperties) {
            // Conditional Bundle Display (Issue #31, Task 7.8)
            // 6-hour bundle conditional logic with stakeholder-requested N/A display
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));

            // Step 1: No sepsis indication at all → BLANK
            if (!hasSevereSepsisIndication(sourceData)) {
                td.innerHTML = '';  // Blank - not a sepsis patient
                return td;
            }

            // Step 2: Has severe sepsis but NOT septic shock → Show N/A
            if (!hasSepticShockIndication(sourceData)) {
                td.innerHTML = '<div style="text-align: center; color: #9ca3af; font-style: italic;">N/A</div>';
                td.style.textAlign = 'center';
                td.style.verticalAlign = 'middle';
                return td;
            }

            // Step 3: Has septic shock → Show icons
            // Get pressor details for tooltip
            const pressorsDetails = sourceData?.PRESSORS_DETAILS || {
                status: value,
                medications: [],
                totalPressors: 0,
                administeredPressors: 0,
                pendingPressors: 0
            };

            // Debug pressor data
            console.log('💊 PRESSORS TOOLTIP DATA:', pressorsDetails);

            // Create tooltip content with Casey's requirements
            let tooltipContent = '<div class="tooltip-timing">';

            // Overall status
            tooltipContent += `
                <div class="tooltip-timing-item" style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                    <span class="tooltip-timing-label" style="font-weight: bold; margin-right: 8px;">Status:</span>
                    <span class="tooltip-timing-value" style="text-align: right;">${pressorsDetails.status || 'Not Ordered'}</span>
                </div>
            `;

            // Pressor count summary
            if (pressorsDetails.totalPressors > 0) {
                tooltipContent += `
                    <div class="tooltip-timing-item" style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                        <span class="tooltip-timing-label" style="font-weight: bold; margin-right: 8px;">Pressors:</span>
                        <span class="tooltip-timing-value" style="text-align: right;">${pressorsDetails.totalPressors} ordered</span>
                    </div>
                `;

                if (pressorsDetails.administeredPressors > 0) {
                    tooltipContent += `
                        <div class="tooltip-timing-item" style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                            <span class="tooltip-timing-label" style="margin-right: 8px;">Administered:</span>
                            <span class="tooltip-timing-value" style="text-align: right; font-weight: bold; color: #059669;">${pressorsDetails.administeredPressors}</span>
                        </div>
                    `;
                }

                if (pressorsDetails.pendingPressors > 0) {
                    tooltipContent += `
                        <div class="tooltip-timing-item" style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                            <span class="tooltip-timing-label" style="margin-right: 8px;">Pending:</span>
                            <span class="tooltip-timing-value" style="text-align: right; color: #d97706;">${pressorsDetails.pendingPressors}</span>
                        </div>
                    `;
                }
            }

            // Pressor medication details
            if (pressorsDetails.medications && pressorsDetails.medications.length > 0) {
                tooltipContent += `
                    <div class="tooltip-timing-item" style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #ddd;">
                        <div style="font-weight: bold; margin-bottom: 4px;">Medications:</div>
                    </div>
                `;
                pressorsDetails.medications.forEach(med => {
                    const medName = med.name || 'Unknown';
                    const medStatus = med.status || 'Unknown';
                    const adminTime = med.administrations > 0 && med.firstAdmin && !med.firstAdmin.includes('Not administered') ?
                                    ` - First: ${med.firstAdmin}` : '';

                    tooltipContent += `
                        <div style="margin-bottom: 2px; font-size: 11px; line-height: 1.3;">
                            <span style="color: #333;">• ${medName}</span><br>
                            <span style="margin-left: 12px; color: #6b7280; font-size: 10px;">(${medStatus})${adminTime}</span>
                        </div>
                    `;
                });
            }

            tooltipContent += '</div>';

            // Use same healthcare icons as other renderers (use column value, not tooltip status)
            let iconHtml = '';
            console.log('💊 PRESSORS RENDERER - Column value:', value, 'Tooltip status:', pressorsDetails.status);
            switch (value) {
                case 'Y':
                    iconHtml = '<div class="progress-completed" aria-label="Pressors administered">✓</div>';
                    break;
                case 'Pend':
                    iconHtml = '<div class="progress-pending" aria-label="Pressors ordered but not administered"></div>';
                    break;
                case 'N':
                    iconHtml = '<div class="progress-not-started" aria-label="No pressors ordered"></div>';
                    break;
                default:
                    iconHtml = '<div style="text-align: center; color: #9ca3af;">--</div>';
            }

            // Create container div
            const containerDiv = document.createElement('div');
            containerDiv.innerHTML = iconHtml;

            // Only show tooltip if there's actual pressor data (Issue #48)
            if (value !== 'N' && value !== 'N/A' && pressorsDetails.medications?.length > 0) {
                createSepsisTooltip(containerDiv, tooltipContent);
            }

            // Clear td and add container
            td.innerHTML = '';
            td.appendChild(containerDiv);
            td.style.textAlign = 'center';
            td.style.verticalAlign = 'middle';
            return td;
        }

        function lactateOrderRenderer(instance, td, row, col, prop, value, cellProperties) {
            // Conditional Bundle Display (Issue #31, Task 7.4)
            // Only show icons if patient has severe sepsis indication
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));

            if (!hasSevereSepsisIndication(sourceData)) {
                td.innerHTML = '';  // Blank cell for non-sepsis patients
                return td;
            }

            // Get lactate order details for tooltip
            const lactateDetails = sourceData?.LACTATE_DETAILS || { status: value, orderId: null, orderMnemonic: null, orderStatus: null, catalogCd: null };

            // Debug what lactate data we're actually getting
            console.log('💉 LACTATE TOOLTIP DATA:', lactateDetails);


            // Create tooltip content based on available timing data

            let tooltipContent = '<div class="tooltip-timing">';

            // Show available order information (based on real Cerner structure)
            const statusText = lactateDetails.orderStatus ||
                              (lactateDetails.status === 'Y' ? 'Completed' :
                               lactateDetails.status === 'Pend' ? 'Pending' : 'Not Ordered');

            tooltipContent += `
                <div class="tooltip-timing-item">
                    <span class="tooltip-timing-label">Status:</span>
                    <span class="tooltip-timing-value">${statusText}</span>
                </div>
            `;

            // Order Time (Casey's requirement - when lactate was ordered)
            if (lactateDetails.orderTime) {
                tooltipContent += `
                    <div class="tooltip-timing-item">
                        <span class="tooltip-timing-label">Ordered:</span>
                        <span class="tooltip-timing-value">${lactateDetails.orderTime}</span>
                    </div>
                `;
            }

            // Result Time (when lab resulted - Casey's requirement for SEP-1 timing)
            if (lactateDetails.collectionTime && lactateDetails.collectionTime !== "") {
                tooltipContent += `
                    <div class="tooltip-timing-item">
                        <span class="tooltip-timing-label">Resulted:</span>
                        <span class="tooltip-timing-value">${lactateDetails.collectionTime}</span>
                    </div>
                `;
            }

            // Order ID (available in real Cerner data)
            if (lactateDetails.orderId) {
                tooltipContent += `
                    <div class="tooltip-timing-item">
                        <span class="tooltip-timing-label">Order ID:</span>
                        <span class="tooltip-timing-value">${lactateDetails.orderId}</span>
                    </div>
                `;
            }

            // Order mnemonic (available in real Cerner data)
            if (lactateDetails.orderMnemonic) {
                tooltipContent += `
                    <div class="tooltip-timing-item">
                        <span class="tooltip-timing-label">Order:</span>
                        <span class="tooltip-timing-value">${lactateDetails.orderMnemonic}</span>
                    </div>
                `;
            }

            // Catalog code (available in real Cerner data)
            if (lactateDetails.catalogCd) {
                tooltipContent += `
                    <div class="tooltip-timing-item">
                        <span class="tooltip-timing-label">Catalog:</span>
                        <span class="tooltip-timing-value">${lactateDetails.catalogCd}</span>
                    </div>
                `;
            }

            tooltipContent += '</div>';

            // Use same healthcare icons as powerplanRenderer but wrapped in tooltip container
            let iconHtml = '';
            switch (lactateDetails.status) {
                case 'Y':
                    iconHtml = '<div class="progress-completed" aria-label="Lactate order completed">✓</div>';
                    break;
                case 'Pend':
                    iconHtml = '<div class="progress-pending" aria-label="Lactate order pending"></div>';
                    break;
                case 'N':
                    iconHtml = '<div class="progress-not-started" aria-label="Lactate not ordered"></div>';
                    break;
                default:
                    iconHtml = '<div style="text-align: center; color: #9ca3af;">--</div>';
            }

            // Create container div with tooltip
            const containerDiv = document.createElement('div');
            containerDiv.className = 'tooltip-container';
            containerDiv.innerHTML = iconHtml;

            // Attach Tippy.js tooltip (Issue #48 - Phase 3.6 - Lactate)
            createSepsisTooltip(containerDiv, tooltipContent);

            // Clear existing content and add new container
            td.innerHTML = '';
            td.appendChild(containerDiv);
            td.style.textAlign = 'center';
            td.style.verticalAlign = 'middle';
            return td;
        }

        function conditionalRenderer(instance, td, row, col, prop, value, cellProperties) {
            // Conditional Bundle Display (Issue #31, Task 7.8)
            // 6-hour bundle conditional logic with stakeholder-requested N/A display
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));

            // Step 1: No sepsis indication at all → BLANK
            if (!hasSevereSepsisIndication(sourceData)) {
                td.innerHTML = '';  // Blank - not a sepsis patient
                return td;
            }

            // Step 2: Has severe sepsis but NOT septic shock → Show N/A
            if (!hasSepticShockIndication(sourceData)) {
                td.innerHTML = '<div style="text-align: center; color: #9ca3af; font-style: italic;">N/A</div>';
                td.style.textAlign = 'center';
                td.style.verticalAlign = 'middle';
                return td;
            }

            // Step 3: Has septic shock → Show icons/circles
            // CONDITIONAL RENDERER for Perfusion, Lac 2, Pressors, and Vol Doc columns
            // Issue #28: Make TBD and N clickable for Perfusion column (PowerForm launch)
            // Issue #47: Use PERFUSION_DETAILS for green checkmark when PowerForm completed
            // Handles N/A (lactate < 4.0), -- (fluids not ordered), TBD (awaiting data source), and Y/N/Pend (when data available)

            // Special handling for Perfusion column ONLY (Issue #47)
            if (prop === 'PERFUSION_ASSESSMENT') {
                const perfusionDetails = sourceData.PERFUSION_DETAILS || {};
                const personId = sourceData.PERSON_ID;
                const encntrId = sourceData.ENCNTR_ID;
                const patientName = sourceData.PATIENT_NAME;

                if (perfusionDetails.completed) {
                    // Perfusion completed → Green checkmark (ALWAYS clickable to launch new instance)
                    const checkmark = document.createElement('div');
                    checkmark.className = 'progress-completed clickable-action';
                    checkmark.setAttribute('aria-label', 'Perfusion assessment completed - click to document new assessment');
                    checkmark.textContent = '✓';

                    // Click handler - Always launches NEW PowerForm instance
                    checkmark.addEventListener('click', function() {
                        console.log('💓 PERFUSION CLICK (completed) - Launching new assessment for:', patientName);
                        if (personId && encntrId && window.PowerFormLauncher) {
                            window.PowerFormLauncher.launchPerfusionAssessment(personId, encntrId);
                        } else {
                            console.error('💓 Missing patient IDs or PowerFormLauncher not loaded');
                        }
                    });

                    // Create tooltip using Tippy.js (Issue #48 - Phase 3.1: 83% code reduction)
                    const tooltipHTML = buildStructuredTooltip({
                        eventType: perfusionDetails.eventCdDisp,
                        completedBy: perfusionDetails.performedPrsnlName,
                        position: perfusionDetails.performedPrsnlPosition,
                        completed: perfusionDetails.completedDateTime,
                        actionMessage: 'Click to document new assessment'
                    });

                    createSepsisTooltip(checkmark, tooltipHTML);

                    td.innerHTML = '';
                    td.appendChild(checkmark);
                    td.style.textAlign = 'center';
                    td.style.verticalAlign = 'middle';
                    return td;
                } else {
                    // Perfusion not completed → Empty circle (clickable)
                    const emptyCircle = document.createElement('div');
                    emptyCircle.className = 'progress-not-started clickable-action';
                    emptyCircle.setAttribute('aria-label', 'Click to document perfusion assessment');

                    // Click handler - Launch new PowerForm
                    emptyCircle.addEventListener('click', function() {
                        console.log('💓 PERFUSION CLICK (not completed) - Patient:', patientName);
                        if (personId && encntrId && window.PowerFormLauncher) {
                            window.PowerFormLauncher.launchPerfusionAssessment(personId, encntrId);
                        } else {
                            console.error('💓 Missing patient IDs or PowerFormLauncher not loaded');
                        }
                    });

                    // Create tooltip using Tippy.js (Issue #48 - Phase 3.1)
                    const emptyTooltipHTML = buildActionTooltip('Click to document Perfusion Assessment');
                    createSepsisTooltip(emptyCircle, emptyTooltipHTML);

                    td.innerHTML = '';
                    td.appendChild(emptyCircle);
                    td.style.textAlign = 'center';
                    td.style.verticalAlign = 'middle';
                    return td;
                }
            }

            // Standard conditional rendering for other columns (Lac 2, Pressors, Vol Doc)
            let htmlContent = '';

            switch (value) {
                case 'N/A':
                    // Lactate < 4.0 - not clinically indicated
                    htmlContent = '<div style="text-align: center; color: #9ca3af; font-style: italic;">N/A</div>';
                    break;
                case '--':
                    // Fluids not ordered - not applicable for volume documentation
                    htmlContent = '<div style="text-align: center; color: #9ca3af;">--</div>';
                    break;
                case 'TBD':
                    // Clinically indicated but not documented (for Lac 2, Pressors, Vol Doc only)
                    // Note: Perfusion TBD handled by special perfusion logic above
                    htmlContent = '<div style="text-align: center; color: #6b7280; font-style: italic;">TBD</div>';
                    break;
                case 'Y':
                    // Intervention completed - use healthcare icon
                    htmlContent = '<div class="progress-completed" aria-label="Intervention completed">✓</div>';
                    break;
                case 'Pend':
                    // Intervention pending - use healthcare icon
                    htmlContent = '<div class="progress-pending" aria-label="Intervention pending"></div>';
                    break;
                case 'N':
                    // Intervention not ordered - simple empty circle (for Lac 2, Pressors, Vol Doc)
                    // Note: Perfusion 'N' handled by special perfusion logic above
                    htmlContent = '<div class="progress-not-started" aria-label="Intervention not ordered"></div>';
                    break;
                default:
                    // No data available
                    htmlContent = '<div style="text-align: center; color: #9ca3af;">--</div>';
            }

            td.innerHTML = htmlContent;
            td.style.textAlign = 'center';
            td.style.verticalAlign = 'middle';
            return td;
        }

        function lactateResultRenderer(instance, td, row, col, prop, value, cellProperties) {
            // Conditional Bundle Display (Issue #31) - Lac 1 Rslt requires sepsis indication
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));

            if (!hasSevereSepsisIndication(sourceData)) {
                td.innerHTML = '';  // Blank - no sepsis indication
                td.style.textAlign = 'center';
                td.style.verticalAlign = 'middle';
                return td;
            }

            // LACTATE RESULT RENDERER with critical value highlighting (BADGE approach v1.32.0)
            // Per Sepsis Data Display Spec: Critical value (≥ 4.0) gets pink badge with red text
            // Badge isolates background from table cell hover effects

            // Check if lactate was ordered (sourceData.LACTATE_ORDERED)
            const lactateOrdered = sourceData?.LACTATE_ORDERED === 'Y' || sourceData?.LACTATE_ORDERED === 'Pend';

            if (value === "--" || value === "" || value === null || value === undefined) {
                // Show "--" only if lactate was ordered (awaiting result)
                // Show blank if lactate not ordered
                if (lactateOrdered) {
                    td.innerHTML = '--';  // Ordered, awaiting result
                    td.style.color = '#9ca3af';
                    td.style.fontWeight = 'normal';
                } else {
                    td.innerHTML = '';  // Not ordered, show blank
                }
            } else {
                // Numeric lactate value
                const numericValue = parseFloat(value);

                if (!isNaN(numericValue) && numericValue >= 4.0) {
                    // Critical value - wrap in badge to isolate from cell hover
                    td.innerHTML = `<span class="lactate-badge-critical">${numericValue.toFixed(1)}</span>`;
                } else if (!isNaN(numericValue)) {
                    // Normal value (< 4.0 mmol/L) - no badge needed
                    td.innerHTML = numericValue.toFixed(1);
                    td.style.color = '#000000'; // Black (v1.33.0)
                    td.style.fontWeight = 'normal';
                } else {
                    // Invalid numeric value
                    td.innerHTML = value;
                    td.style.color = '#9ca3af'; // Gray for invalid
                    td.style.fontWeight = 'normal';
                }
            }

            td.style.textAlign = 'center';
            td.style.verticalAlign = 'middle';
            return td;
        }

        // ========================================
        // DATE/TIME UTILITIES (Issue #62)
        // ========================================

        /**
         * Parse Cerner date/time strings to Date objects
         * Format: "mm/dd/yy hh:mm" (e.g., "11/13/25 04:54", "12/09/24 13:09")
         *
         * @param {string} dateString - Cerner formatted date string
         * @returns {Date|null} - Date object or null if invalid
         *
         * Issue #62: Required for temporal order validation (cultures BEFORE antibiotics)
         */
        function parseDateTime(dateString) {
            if (!dateString || dateString === '--' || dateString === '' || dateString.includes('1900-01-01')) {
                return null;
            }

            try {
                // Format: "mm/dd/yy hh:mm"
                const parts = dateString.trim().match(/^(\d{1,2})\/(\d{1,2})\/(\d{2})\s+(\d{1,2}):(\d{2})$/);

                if (!parts) {
                    console.warn('[parseDateTime] Invalid format:', dateString);
                    return null;
                }

                const month = parseInt(parts[1], 10) - 1; // JavaScript months are 0-indexed
                const day = parseInt(parts[2], 10);
                const year = parseInt(parts[3], 10);
                const hours = parseInt(parts[4], 10);
                const minutes = parseInt(parts[5], 10);

                // Year 2000 handling: Assume 00-49 = 2000-2049, 50-99 = 1950-1999
                const fullYear = year < 50 ? 2000 + year : 1900 + year;

                const dateObj = new Date(fullYear, month, day, hours, minutes, 0, 0);

                // Validate the date is valid (not NaN)
                if (isNaN(dateObj.getTime())) {
                    console.warn('[parseDateTime] Invalid date created:', dateString);
                    return null;
                }

                return dateObj;

            } catch (error) {
                console.error('[parseDateTime] Error parsing date:', dateString, error);
                return null;
            }
        }

        /**
         * Calculate minutes between two dates
         * @param {Date} fromDate - Start date (earlier)
         * @param {Date} toDate - End date (later)
         * @returns {number|null} - Minutes difference (negative if toDate before fromDate)
         */
        function calculateMinutesDifference(fromDate, toDate) {
            if (!fromDate || !toDate) return null;
            const diffMs = toDate - fromDate;
            return Math.floor(diffMs / 60000); // Convert milliseconds to minutes
        }

        /**
         * Format minutes as "Xh Ym" (e.g., "0h 41m", "2h 16m", "3h 45m")
         * @param {number} minutes - Total minutes
         * @returns {string} - Formatted string
         */
        function formatMinutesAsHoursMinutes(minutes) {
            if (minutes === null || minutes === undefined || isNaN(minutes)) return '--';
            if (minutes < 0) return `${Math.abs(minutes)}m before`;

            const hours = Math.floor(minutes / 60);
            const mins = minutes % 60;
            return `${hours}h ${mins}m`;
        }

        /**
         * Check temporal order: Blood cultures BEFORE antibiotics (CMS SEP-1 requirement)
         *
         * @param {Object} patient - Patient data object
         * @returns {Object} - {valid: boolean, culturesTime: string, antibioticsTime: string, violation: string|null}
         *
         * Issue #62: CRITICAL - SEP-1 requires cultures obtained BEFORE antibiotics administered
         * If antibiotics given before cultures → TIMING VIOLATION → Bundle fails
         */
        function checkCulturesBeforeAntibiotics(patient) {
            const result = {
                valid: true,
                culturesTime: null,
                antibioticsTime: null,
                violation: null,
                culturesDate: null,
                antibioticsDate: null
            };

            // Get blood cultures array from patient data
            const bloodCultures = patient.BLOOD_CULTURES_DETAILS?.bloodCultures || [];
            const antibiotics = patient.ANTIBIOTICS_DETAILS?.antibiotics || [];

            if (bloodCultures.length === 0 || antibiotics.length === 0) {
                // Can't validate without both - assume valid (handled by basic bundle check)
                return result;
            }

            // Find FIRST (earliest) blood culture collected time
            let earliestCultureTime = null;
            let earliestCultureDate = null;

            for (const culture of bloodCultures) {
                const collectedTime = culture.collectedTime;
                if (!collectedTime || collectedTime === '--') continue;

                const cultureDate = parseDateTime(collectedTime);
                if (!cultureDate) continue;

                if (!earliestCultureDate || cultureDate < earliestCultureDate) {
                    earliestCultureDate = cultureDate;
                    earliestCultureTime = collectedTime;
                }
            }

            // Find FIRST (earliest) antibiotic administration time
            let earliestAntibioticTime = null;
            let earliestAntibioticDate = null;

            for (const antibiotic of antibiotics) {
                const adminTime = antibiotic.firstAdminTime;
                if (!adminTime || adminTime === 'Not administered' || adminTime === '--') continue;

                const adminDate = parseDateTime(adminTime);
                if (!adminDate) continue;

                if (!earliestAntibioticDate || adminDate < earliestAntibioticDate) {
                    earliestAntibioticDate = adminDate;
                    earliestAntibioticTime = adminTime;
                }
            }

            // Can't validate if either time missing
            if (!earliestCultureDate || !earliestAntibioticDate) {
                return result;
            }

            // CRITICAL CHECK: Cultures MUST be before antibiotics
            result.culturesTime = earliestCultureTime;
            result.antibioticsTime = earliestAntibioticTime;
            result.culturesDate = earliestCultureDate;
            result.antibioticsDate = earliestAntibioticDate;

            if (earliestCultureDate >= earliestAntibioticDate) {
                // TIMING VIOLATION: Cultures collected AFTER (or same time as) antibiotics
                result.valid = false;
                result.violation = `Blood cultures collected AFTER antibiotics administered (SEP-1 violation)`;
            }

            return result;
        }

        /**
         * Generate 3-Hour Bundle Compliance Tooltip HTML
         *
         * @param {Object} patient - Patient data object
         * @returns {string} - HTML tooltip content
         *
         * Issue #62: Shows complete bundle checklist with timing, violations, and failure reasons
         * Follows CMS SEP-1 guidelines and Issue #62 tooltip examples
         */
        function create3HourBundleTooltip(patient) {
            let html = '<div style="font-family: sans-serif; font-size: 11px; line-height: 1.5;">';

            // Header
            html += '<div style="font-weight: bold; font-size: 12px; margin-bottom: 8px; border-bottom: 1px solid #ccc; padding-bottom: 4px;">';
            html += '3-Hour SEP-1 Bundle';
            html += '</div>';

            // Time Zero
            const timeZeroStr = patient.TIME_ZERO_DETAILS?.timestamp || '--';
            html += `<div style="margin-bottom: 8px; color: #666;">Time Zero: ${timeZeroStr}</div>`;

            const timeZero = parseDateTime(timeZeroStr);
            const failures = [];

            // Element 1: Lactate
            const lactateValue = patient.LACTATE_RESULT;
            const lactateOrdered = patient.LACTATE_ORDERED === 'Y';

            if (lactateOrdered && lactateValue && lactateValue !== '--') {
                html += `<div style="margin-bottom: 4px;">`;
                html += `✓ Lactate: ${lactateValue} mmol/L</div>`;
            } else if (lactateOrdered) {
                html += `<div style="margin-bottom: 4px;">`;
                html += `✓ Lactate: Ordered</div>`;
            } else {
                html += `<div style="margin-bottom: 4px; color: #dc2626;">`;
                html += `✗ Lactate: Not ordered</div>`;
                failures.push('Lactate not ordered');
            }

            // Element 2: Blood Cultures (with temporal order check)
            const culturesOrdered = patient.BLOOD_CULTURES_ORDERED === 'Y';
            const temporalCheck = checkCulturesBeforeAntibiotics(patient);

            if (culturesOrdered) {
                if (!temporalCheck.valid) {
                    // TIMING VIOLATION - Show detailed explanation
                    html += `<div style="margin-bottom: 4px; color: #dc2626;">`;
                    html += `✗ Blood Cultures: Collected ${temporalCheck.culturesTime}<br>`;
                    html += `<span style="margin-left: 12px;">→ Obtained AFTER antibiotics ✗ TIMING VIOLATION</span><br>`;
                    html += `<span style="margin-left: 12px;">→ Antibiotics administered: ${temporalCheck.antibioticsTime}</span><br>`;
                    html += `<span style="margin-left: 12px;">→ ⚠️ SEP-1 requires cultures BEFORE antibiotics</span>`;
                    html += `</div>`;
                    failures.push('timing violation');
                } else if (temporalCheck.culturesTime) {
                    // Valid order - Don't state the obvious (Issue #62 feedback)
                    html += `<div style="margin-bottom: 4px;">`;
                    html += `✓ Blood Cultures: Collected ${temporalCheck.culturesTime}</div>`;
                } else {
                    html += `<div style="margin-bottom: 4px;">`;
                    html += `✓ Blood Cultures: Ordered</div>`;
                }
            } else {
                html += `<div style="margin-bottom: 4px; color: #dc2626;">`;
                html += `✗ Blood Cultures: Not ordered</div>`;
                failures.push('Blood cultures not ordered');
            }

            // Element 3: Antibiotics (don't repeat time if shown in violation above)
            const antibioticsGiven = patient.ANTIBIOTICS_ORDERED === 'Y';

            if (antibioticsGiven) {
                // Only show time if NOT already shown in timing violation
                if (temporalCheck.antibioticsTime && temporalCheck.valid) {
                    html += `<div style="margin-bottom: 4px;">`;
                    html += `✓ Antibiotics: Administered ${temporalCheck.antibioticsTime}</div>`;
                } else {
                    html += `<div style="margin-bottom: 4px;">`;
                    html += `✓ Antibiotics: Administered</div>`;
                }
            } else {
                html += `<div style="margin-bottom: 4px; color: #dc2626;">`;
                html += `✗ Antibiotics: Not ordered</div>`;
                failures.push('Antibiotics not ordered');
            }

            // Element 4: Fluids (conditional)
            const lactateFloat = parseFloat(lactateValue);
            const fluidsRequired = lactateFloat >= 4.0;
            const fluidsOrdered = patient.SEPSIS_FLUID_ORDERED === 'Y';

            if (fluidsRequired) {
                if (fluidsOrdered) {
                    html += `<div style="margin-bottom: 4px;">`;
                    html += `✓ Fluids: Required (lactate ${lactateValue} ≥ 4.0) - Administered</div>`;
                } else {
                    html += `<div style="margin-bottom: 4px; color: #dc2626;">`;
                    html += `✗ Fluids: Required (lactate ${lactateValue} ≥ 4.0) - Not administered</div>`;
                    failures.push('Fluids required but not administered');
                }
            } else {
                html += `<div style="margin-bottom: 4px;">`;
                html += `✓ Fluids: Not required (lactate ${lactateValue || '--'} &lt; 4.0)</div>`;
            }

            // Summary (concise - details already shown above)
            html += '<div style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #ccc; font-weight: bold;">';
            if (failures.length === 0 && temporalCheck.valid) {
                html += '<span style="color: #16a34a;">Bundle Status: COMPLETE ✓</span>';
            } else {
                html += '<span style="color: #dc2626;">Bundle Status: INCOMPLETE ✗</span>';
            }
            html += '</div>';

            html += '</div>';
            return html;
        }

        // Check if 3-hour bundle is complete (Issue #17)
        // SEP-1 3-Hour Bundle Elements (all required):
        // 1. Lactate measured, 2. Blood cultures obtained, 3. Antibiotics given, 4. Fluids (if required)
        function check3HourBundleComplete(patient) {
            // Required for ALL patients
            const lactateOrdered = patient.LACTATE_ORDERED === 'Y';

            // ISSUE #19: Blood Cultures - SEP-1 Element 2 "Obtain blood cultures before antibiotics"
            // Uses bloodcultures[] array with dept statuses (Collected/In-Lab/Completed)
            // NOTE: patient.BLOOD_CULTURES_ORDERED field is calculated from bloodcultures[] array
            // Do NOT directly check that field - PatientDataService determines it from dept statuses
            // PENDING CASEY VALIDATION: Confirm "Collected" = complete for SEP-1 audit
            const culturesOrdered = patient.BLOOD_CULTURES_ORDERED === 'Y';

            const antibioticsGiven = patient.ANTIBIOTICS_ORDERED === 'Y';

            // Element 4: Fluids - CONDITIONAL (Issue #16 Phase 1 logic)
            // CRITICAL: Must use EXACT same logic as fluidsRenderer
            const lactateValue = patient.LACTATE_RESULT;
            const fluidsRequired = lactateValue !== null && lactateValue !== undefined &&
                                   lactateValue !== '' && lactateValue !== '--' &&
                                   parseFloat(lactateValue) >= 4.0;

            // If fluids NOT required (lactate <4.0), fluidsComplete = TRUE
            // If fluids required (lactate ≥4.0), check if given
            const fluidsComplete = !fluidsRequired || patient.SEPSIS_FLUID_ORDERED === 'Y';

            // "All or Nothing" - ALL required elements must be met
            // Issue #62: CRITICAL - Must also validate temporal order (cultures BEFORE antibiotics)
            const temporalCheck = checkCulturesBeforeAntibiotics(patient);
            const bundleComplete = lactateOrdered && culturesOrdered && antibioticsGiven && fluidsComplete && temporalCheck.valid;

            console.log('🎯 BUNDLE CHECK Patient:', patient.PATIENT_NAME);
            console.log('🎯 Lactate Value:', lactateValue, 'Fluids Required:', fluidsRequired);
            console.log('🎯 Lac:', lactateOrdered, 'Cultures:', culturesOrdered, 'Abx:', antibioticsGiven, 'FluidsReq:', fluidsRequired, 'FluidsComplete:', fluidsComplete);
            console.log('🎯 Temporal Order Valid:', temporalCheck.valid, '| Violation:', temporalCheck.violation || 'None');
            console.log('🎯 → Bundle Complete:', bundleComplete);

            return bundleComplete;
        }

        function bundleTimerRenderer(instance, td, row, col, prop, value, cellProperties) {
            // Conditional Bundle Display (Issue #31) - Timer requires sepsis indication
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));

            if (!hasSevereSepsisIndication(sourceData)) {
                td.innerHTML = '';  // Blank cell - no timer without sepsis indication
                return td;
            }

            // 3-HR BUNDLE TIMER RENDERER with urgency color coding (BADGE approach v1.32.0)
            // v1.34.0: Shows bundle completion status when timer expires (Issue #17)
            // Orange badge for < 1 hour remaining (0h 00m through 0h 59m)
            // Badge isolates background from table cell hover effects

            const minutesRemaining = sourceData?.SEPSIS_TIMER_SORT;

            td.style.textAlign = 'center';
            td.style.verticalAlign = 'middle';

            // Apply color coding based on urgency and bundle completion (v1.34.0)
            if (minutesRemaining !== null && minutesRemaining !== undefined) {
                if (minutesRemaining > 0 && minutesRemaining < 60) {
                    // Less than 1 hour but NOT expired - orange badge urgency
                    td.innerHTML = `<span class="timer-badge-urgent">${value || ''}</span>`;
                } else if (minutesRemaining > 0) {
                    // 1+ hours remaining - normal countdown display
                    td.textContent = value || '';
                    td.style.color = '#000000';
                    td.style.fontWeight = 'normal';
                } else {
                    // Timer EXPIRED (minutesRemaining ≤ 0) - Show bundle completion status (Issue #17, #62)
                    const bundleComplete = check3HourBundleComplete(sourceData);

                    if (bundleComplete) {
                        // All elements met - Green checkmark (same as PowerPlan "Y")
                        td.innerHTML = '<div class="progress-completed" aria-label="3-hour bundle complete">✓</div>';
                    } else {
                        // Bundle incomplete - Red X
                        td.innerHTML = '<div class="bundle-failed" aria-label="3-hour bundle incomplete">✗</div>';
                    }

                    // Issue #62: Add tooltip showing bundle checklist with compliance details
                    const bundleTooltipContent = create3HourBundleTooltip(sourceData);
                    const bundleIcon = td.querySelector('.progress-completed, .bundle-failed');

                    if (bundleIcon && bundleTooltipContent) {
                        createSepsisTooltip(bundleIcon, bundleTooltipContent);
                    }
                }
            } else {
                // Dashboard cleanup (Issue #31) - Show blank instead of "--"
                td.textContent = value || '';
                td.style.color = '#9ca3af'; // Gray for no data
                td.style.fontWeight = 'normal';
            }

            return td;
        }

        function patientNameRenderer(instance, td, row, col, prop, value, cellProperties) {

            // PATIENT NAME RENDERER with PowerChart navigation (from proven respiratory MPage approach)
            // Get source data to access patient IDs for navigation
            const sourceData = instance.getSourceDataAtRow(instance.toPhysicalRow(row));

            // Debug patient data availability
            console.log('👤 PATIENT NAME RENDERER - Row:', row, 'Value:', value);
            console.log('👤 Source data:', sourceData);

            // Check for required patient IDs (preserved in table data)
            const personId = sourceData?.PERSON_ID || sourceData?.personId;
            const encntrId = sourceData?.ENCNTR_ID || sourceData?.encntrId;

            console.log('👤 Person ID:', personId, 'Encounter ID:', encntrId);

            if (personId && encntrId) {
                // Construct APPLINK URL using proven respiratory MPage approach
                const appLink = `javascript:;APPLINK(0, '$APP_APPNAME$', '/PERSONID=${personId} /ENCNTRID=${encntrId} /FIRSTTAB=^^')`;

                console.log('👤 Creating link with appLink:', appLink);

                // Create clickable hyperlink (v1.33.0)
                td.innerHTML = `<a href="${appLink}" class="patient-name-link">${value}</a>`;

                console.log('👤 td.innerHTML after setting:', td.innerHTML);

                // CRITICAL FIX: Force link color using JavaScript (bypasses CSS cascade issues)
                // setProperty with 'important' flag has highest priority, applied AFTER Handsontable internal CSS
                const link = td.querySelector('a');
                console.log('👤 Link element found:', link);
                if (link) {
                    link.style.setProperty('color', '#0066cc', 'important');
                    link.style.setProperty('cursor', 'pointer', 'important');
                    console.log('👤 Link color set to:', link.style.color);
                } else {
                    console.error('👤 ERROR: Link element not found after setting innerHTML!');
                }
            } else {
                console.log('👤 No person/encounter IDs - using plain text');
                // Fallback for missing patient IDs
                td.innerHTML = value;
                td.style.color = '#000000'; // Black for non-link names
            }

            td.style.textAlign = 'left';
            td.style.verticalAlign = 'middle';
            return td;
        }

        // Define columns for sepsis dashboard structure (16 columns - Priority hidden pending requestor input)
        // v1.33.0: Left-justified columns for text fields, center for icons/values
        console.log('Defining demographics columns for Mobility Dashboard...');
        const columns = [
            { data: 'PATIENT_NAME', title: 'Patient', width: 160, renderer: patientNameRenderer, className: 'htMiddle htLeft' },
            { data: 'UNIT', title: 'Unit', width: 100, className: 'htMiddle htLeft' },
            { data: 'ROOM_BED', title: 'Room/Bed', width: 100, className: 'htMiddle htLeft' },
            { data: 'AGE', title: 'Age', width: 60, className: 'htMiddle htCenter' },
            { data: 'GENDER', title: 'Gender', width: 80, className: 'htMiddle htCenter' },
            { data: 'PATIENT_CLASS', title: 'Class', width: 120, className: 'htMiddle htLeft' },
            { data: 'ADMISSION_DATE', title: 'Admitted', width: 120, className: 'htMiddle htCenter' },
            { data: 'STATUS', title: 'Status', width: 100, className: 'htMiddle htLeft' }

            /* SEPSIS COLUMNS - REMOVED FOR MOBILITY DASHBOARD
            { data: 'ALERT_TYPE', title: 'Alert', width: 85, renderer: alertRenderer, className: 'htMiddle htLeft' },
            { data: 'SEPSIS_SCREEN_ASSESSMENT', title: 'Screen', width: 60, renderer: screenAssessmentRenderer, className: 'htMiddle htLeft' },
            { data: 'LAST_SEPSIS_SCREEN', title: 'Time Zero', width: 140, renderer: timeZeroRenderer, className: 'htMiddle htLeft' },
            { data: 'SEPSIS_TIMER', title: '3-Hr Timer', width: 110, renderer: bundleTimerRenderer, className: 'htMiddle htCenter' },
            { data: 'POWERPLAN_ORDERED', title: 'PowerPlan', width: 75, renderer: powerplanRenderer, className: 'htMiddle htCenter' },
            { data: 'LACTATE_ORDERED', title: 'Lac 1', width: 50, renderer: lactateOrderRenderer, className: 'htMiddle htCenter' },
            { data: 'LACTATE_RESULT', title: 'Lac 1 Rslt', width: 60, renderer: lactateResultRenderer, className: 'htMiddle htCenter' },
            { data: 'BLOOD_CULTURES_ORDERED', title: 'Cultures', width: 65, renderer: bloodCulturesRenderer, className: 'htMiddle htCenter' },
            { data: 'ANTIBIOTICS_ORDERED', title: 'Abx', width: 45, renderer: antibioticsOrderRenderer, className: 'htMiddle htCenter' },
            { data: 'SEPSIS_FLUID_ORDERED', title: 'Fluids', width: 60, renderer: fluidsRenderer, className: 'htMiddle htCenter' },
            { data: 'REPEAT_LACTATE_ORDERED', title: 'Lac 2', width: 50, renderer: conditionalRenderer, className: 'htMiddle htCenter' },
            { data: 'PERFUSION_ASSESSMENT', title: 'Perfusion', width: 70, renderer: conditionalRenderer, className: 'htMiddle htCenter' },
            { data: 'SEPSIS_PRESSORS', title: 'Pressors', width: 60, renderer: pressorsRenderer, className: 'htMiddle htCenter' }
            */
        ];

        /* DEMOGRAPHICS: All columns now shown above
        { data: 'SEPSIS_PRIORITY', title: 'Priority', width: 60 },
        { data: 'ACUITY', title: 'Acuity', width: 90, renderer: acuityRenderer }
        */
        
        // Debug the data being passed to table
        console.log('Patient data for table:', data);
        console.log('Columns configuration:', columns);

        // Calculate height for PowerChart container compatibility
        const rowHeight = 35; // Approximate row height in pixels
        const headerHeight = 45; // Header row height
        const padding = 20; // Extra padding for borders/spacing
        const calculatedHeight = (data.length * rowHeight) + headerHeight + padding;
        const minHeight = 300; // Minimum height for usability
        const maxHeight = Math.min(window.innerHeight - 100, 800); // PowerChart-compatible max height

        // Use calculated height but respect PowerChart container limits
        const optimalHeight = Math.min(Math.max(calculatedHeight, minHeight), maxHeight);

        console.log(`Handsontable height calculation: ${data.length} patients * ${rowHeight}px + ${headerHeight}px + ${padding}px = ${calculatedHeight}px (using ${optimalHeight}px - PowerChart compatible)`);

        // Create table once or update existing (smooth refresh pattern from mobility-demo)
        if (!app.state.handsontableInstance) {
            // First time: Create new Handsontable
            console.log('Creating new Handsontable instance...');
            app.state.handsontableInstance = new Handsontable(tableDiv, {
            data: data,
            columns: columns,
            colHeaders: true,
            nestedHeaders: [
                [
                    { label: 'Patient Demographics', colspan: 8 }  // All 8 demographics columns
                ],
                columns.map(col => col.title)  // Column headers as second row
            ],
            width: '100%',
            height: optimalHeight, // Use calculated height to prevent scrollbar
            maxRows: data.length,
            licenseKey: 'non-commercial-and-evaluation',
            readOnly: true,
            stretchH: 'all',
            rowHeights: 32, // Fixed compact height - prevents wrapping and scrolling
            rowHeaders: false, // Remove problematic row numbers on left side
            contextMenu: false,
            manualColumnResize: true,
            manualRowResize: false, // Prevent manual row resizing
            filters: true,
            dropdownMenu: ['filter_by_condition', 'filter_by_value', 'filter_action_bar'], // Issue #39 - Specific dropdown items
            columnSorting: {
                initialConfig: {
                    column: 2,  // Room/Bed column (0=Patient, 1=Unit, 2=Room/Bed)
                    sortOrder: 'asc'  // Ascending order (ER-1, ER-2, ER-10)
                }
            },
            sortIndicator: true,
            // Alternating row colors (v1.32.0 - match Clinical Leader Organizer)
            // v1.33.0: Apply left/center alignment based on column
            cells: function(row, col) {
                const cellProperties = {};
                // Left-justified columns: 0-5 (Patient, Unit, Room/Bed, Alert, Screen, Time Zero)
                // Center-justified columns: 6-15 (all others)
                const alignment = (col <= 5) ? 'htLeft' : 'htCenter';

                // Add alternating row class for zebra striping
                if (row % 2 === 0) {
                    cellProperties.className = `htMiddle ${alignment} even-row`;
                } else {
                    cellProperties.className = `htMiddle ${alignment} odd-row`;
                }
                return cellProperties;
            }
        });

            // PowerPlan Quick Launch POC - Click handler for PowerPlan circles (Issue #29, Task 3.3 + 4.3)
            app.state.handsontableInstance.addHook('afterOnCellMouseDown', function(event, coords, TD) {
            // Only handle clicks on PowerPlan column (column 7)
            if (coords.col === 7) {
                // Check if clicked element has clickable-action class
                const clickedElement = event.target;
                if (clickedElement && clickedElement.classList.contains('clickable-action')) {
                    // Get the patient data for this row
                    const sourceData = app.state.handsontableInstance.getSourceDataAtRow(coords.row);

                    // Log for POC
                    console.log('PowerPlan Quick Launch - Clicked for patient:', {
                        patientName: sourceData.PATIENT_NAME,
                        encounterId: sourceData.ENCNTR_ID,
                        personId: sourceData.PERSON_ID,
                        alertType: sourceData.ALERT_TYPE,
                        powerplanStatus: sourceData.POWERPLAN_ORDERED
                    });

                    // Task 4.3: Launch PowerPlan using MOEW API
                    if (window.PowerPlanLauncher) {
                        // Show loading indicator
                        const loadingOverlay = document.createElement('div');
                        loadingOverlay.id = 'powerplan-loading';
                        loadingOverlay.innerHTML = `
                            <div style="position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                                        background: rgba(0,0,0,0.5); z-index: 9999;
                                        display: flex; align-items: center; justify-content: center;">
                                <div style="background: white; padding: 30px; border-radius: 8px;
                                            text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.3);">
                                    <div style="font-size: 40px; color: #0066cc; margin-bottom: 15px;">
                                        <i class="fas fa-circle-notch fa-spin"></i>
                                    </div>
                                    <div style="font-size: 16px; font-weight: bold; color: #333;">
                                        Loading PowerPlan...
                                    </div>
                                    <div style="font-size: 14px; color: #666; margin-top: 8px;">
                                        Patient: ${sourceData.PATIENT_NAME}
                                    </div>
                                </div>
                            </div>
                        `;
                        document.body.appendChild(loadingOverlay);

                        const launcher = new window.PowerPlanLauncher();
                        launcher.launchPowerPlan(sourceData)
                            .then(result => {
                                console.log('PowerPlan launched successfully:', result);
                                // Remove loading indicator
                                const overlay = document.getElementById('powerplan-loading');
                                if (overlay) overlay.remove();
                            })
                            .catch(error => {
                                console.error('Error launching PowerPlan:', error);
                                // Remove loading indicator
                                const overlay = document.getElementById('powerplan-loading');
                                if (overlay) overlay.remove();
                                alert('Error launching PowerPlan: ' + error.message);
                            });
                    } else {
                        console.error('PowerPlanLauncher not loaded');
                        alert('PowerPlanLauncher service not available');
                    }
                }
            }
            });

            // Add CSS for consistent cell alignment (only once on table creation)
            const style = document.createElement('style');
        style.textContent = `
            .handsontable td {
                vertical-align: middle !important;
                line-height: 32px !important;
                height: 32px !important;
                white-space: nowrap !important;
                overflow: hidden !important;
                text-overflow: ellipsis !important;
                /* No global color rule - let individual renderers control text color */
            }
            .handsontable td.htCenter {
                text-align: center !important;
            }
            .handsontable td.htLeft {
                text-align: left !important;
                padding-left: 6px !important; /* Small padding to match headers */
            }
            .handsontable .htMiddle {
                vertical-align: middle !important;
            }

            /* Left-align column headers for text columns (v1.33.0) */
            /* Target ONLY second row (column headers), NOT first row (group headers) */
            /* Group headers stay centered, column headers left-aligned */
            .handsontable thead tr:nth-child(2) th:nth-child(1),
            .handsontable thead tr:nth-child(2) th:nth-child(2),
            .handsontable thead tr:nth-child(2) th:nth-child(3),
            .handsontable thead tr:nth-child(2) th:nth-child(4),
            .handsontable thead tr:nth-child(2) th:nth-child(5),
            .handsontable thead tr:nth-child(2) th:nth-child(6) {
                text-align: left !important;
            }

            /* Patient name link styling (v1.33.0) */
            .patient-name-link {
                color: #0066cc !important;
                text-decoration: none !important; /* No underline by default */
                cursor: pointer;
            }
            .patient-name-link:hover {
                text-decoration: underline !important; /* Underline on hover */
            }

            /* Tooltip containers in left-aligned cells should also be left-aligned (v1.33.0) */
            /* Override styles.css justify-content: center with very high specificity */
            .handsontable tbody tr td.htLeft .tooltip-container {
                text-align: left !important;
                display: block !important; /* Use block instead of flex to avoid centering */
                justify-content: flex-start !important; /* Override center from styles.css */
                align-items: flex-start !important;
                width: 100%;
            }
            .handsontable tbody tr td.htLeft .tooltip-container span {
                display: block !important; /* Make spans block-level to respect left alignment */
                text-align: left !important;
                width: 100%;
            }

            /* Badge styles for timer and lactate (v1.32.0 - isolate backgrounds from cell hover) */
            .timer-badge-urgent {
                display: inline-block;
                padding: 2px 6px;
                background-color: #fed7aa; /* Light orange */
                color: #c2410c; /* Dark orange text */
                font-weight: bold;
                border-radius: 3px;
                line-height: 1.2; /* Compact line height */
                font-size: 0.875rem; /* Slightly smaller for pill effect */
            }

            .lactate-badge-critical {
                display: inline-block;
                padding: 2px 6px;
                background-color: #fee2e2; /* Pink background */
                color: #dc2626; /* Red text */
                font-weight: bold;
                border-radius: 3px;
                line-height: 1.2; /* Compact line height */
                font-size: 0.875rem; /* Slightly smaller for pill effect */
            }

            /* Alternating row colors (v1.32.0 - Clinical Leader Organizer style) */
            /* First data row = white, second = gray, third = white, etc. */
            .handsontable tbody tr:nth-child(odd) td {
                background-color: #ffffff; /* White on data rows 0,2,4,6 */
            }
            .handsontable tbody tr:nth-child(even) td {
                background-color: #f3f4f6; /* Gray on data rows 1,3,5,7 */
            }

            /* Force alternating colors to remain during row hover (override Handsontable built-in) */
            /* Only apply to cells NOT being hovered */
            .handsontable tbody tr:nth-child(odd):hover td:not(:hover) {
                background-color: #ffffff !important; /* Force white to stay white */
            }
            .handsontable tbody tr:nth-child(even):hover td:not(:hover) {
                background-color: #f3f4f6 !important; /* Force gray to stay gray */
            }

            /* Cell hover highlighting (v1.32.0 - single cell only) */
            /* Light blue on hovered cell, overrides alternating colors */
            .handsontable tbody tr:nth-child(odd):hover td:hover,
            .handsontable tbody tr:nth-child(even):hover td:hover {
                background-color: #dbeafe !important; /* Light blue on hovered cell */
                cursor: pointer;
            }

            /* Keep tooltip containers transparent */
            .handsontable td:hover .tooltip-container,
            .tooltip-container:hover {
                background-color: transparent;
            }

            /* Patient name link hover underline (v1.33.0) */
            a.patient-name-link:hover {
                text-decoration: underline !important;
            }

            /* Bundle completion failure icon (v1.34.0 - Issue #17) */
            /* Red circle with white X - matches healthcare order status icons */
            .bundle-failed {
                width: 14px;
                height: 14px;
                background-color: #dc2626; /* Red */
                border: 1px solid transparent;
                border-radius: 50%;
                color: white;
                box-sizing: border-box;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 8px;
                font-weight: bold;
                margin: 0 auto;
            }
        `;
            document.head.appendChild(style);

            console.log(`Patient table created with ${data.length} patients`);
        } else {
            // Table exists: Update data only (smooth refresh - no destroy/recreate)
            console.log(`Updating existing Handsontable with ${data.length} patients...`);
            app.state.handsontableInstance.updateSettings({
                data: data,
                height: optimalHeight,
                maxRows: data.length,
                mergeCells: [],  // Clear any merged cells from message display
                cells: function(row, col) {  // Restore normal cell styling
                    const cellProperties = {};
                    const alignment = (col <= 5) ? 'htLeft' : 'htCenter';

                    if (row % 2 === 0) {
                        cellProperties.className = `htMiddle ${alignment} even-row`;
                    } else {
                        cellProperties.className = `htMiddle ${alignment} odd-row`;
                    }
                    return cellProperties;
                }
            });
            console.log(`Patient table updated with ${data.length} patients`);
        }

        // Always render after create or update
        app.state.handsontableInstance.render();
    }

    /**
     * Format time for refresh button display
     */
    function formatTime(date) {
        return date.toLocaleTimeString('en-US', {
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        });
    }

    /**
     * Update last refresh time display
     */
    function updateLastRefreshTime() {
        const timeSpan = document.querySelector('#refresh-data .last-refresh-time');
        if (timeSpan) {
            timeSpan.textContent = formatTime(new Date());
        }
    }

    /**
     * Enable refresh button
     */
    function enableRefreshButton() {
        const refreshButton = document.getElementById('refresh-data');
        if (refreshButton) {
            refreshButton.classList.remove('refreshing');
            refreshButton.disabled = false;
            updateLastRefreshTime();
        }
        debugLog('Refresh button enabled');
    }

    /**
     * Disable refresh button
     */
    function disableRefreshButton() {
        const refreshButton = document.getElementById('refresh-data');
        if (refreshButton) {
            refreshButton.disabled = true;
        }
        debugLog('Refresh button disabled');
    }

    // ==========================================
    // Auto-Refresh Service (Issue #35, Task 8.2)
    // ==========================================

    let autoRefreshTimer = null;
    let autoRefreshCountdown = null;
    let nextRefreshTime = null;

    /**
     * Start auto-refresh service
     */
    function startAutoRefresh() {
        const config = window.AUTO_REFRESH_CONFIG;
        if (!config.enabled) {
            debugLog('Auto-refresh not enabled in config', 'warn');
            return;
        }

        const app = window.PatientListApp;
        // Issue #78: Support auto-refresh for both patient lists AND ER units
        if (!app.state.currentListId && !app.state.currentERUnit) {
            debugLog('Cannot start auto-refresh: no patient list or ER unit selected', 'warn');
            return;
        }

        // Stop existing timer if any
        stopAutoRefresh();

        const intervalMs = config.intervalMinutes * 60 * 1000;
        debugLog(`Starting auto-refresh with ${config.intervalMinutes} minute interval`);

        // Set next refresh time
        nextRefreshTime = new Date(Date.now() + intervalMs);

        // Start countdown timer (updates every second)
        autoRefreshCountdown = setInterval(updateCountdownDisplay, 1000);

        // Start refresh timer
        autoRefreshTimer = setInterval(() => {
            debugLog('🔄 Auto-refresh triggered');

            // Capture current filter state BEFORE refresh
            const filterState = captureFilterState();
            debugLog('📸 Captured filter state', 'debug', filterState);

            // Update next refresh time IMMEDIATELY to prevent countdown going negative
            nextRefreshTime = new Date(Date.now() + intervalMs);
            updateCountdownDisplay();

            // Issue #78: Reload data based on what's selected (patient list OR ER unit)
            const loadPromise = app.state.currentListId
                ? loadPatientData(app.state.currentListId)
                : loadERUnitData(app.state.currentERUnit);

            loadPromise.then(() => {
                debugLog('✅ Auto-refresh data loaded, restoring filters...');
                // Restore filter state AFTER data loads
                restoreFilterState(filterState);
            }).catch(error => {
                debugLog('❌ Auto-refresh failed: ' + error.message, 'error');
            });
        }, intervalMs);

        // Update UI
        updateAutoRefreshUI();
        updateCountdownDisplay();

        debugLog('Auto-refresh started successfully');
    }

    /**
     * Stop auto-refresh service
     */
    function stopAutoRefresh() {
        if (autoRefreshTimer) {
            clearInterval(autoRefreshTimer);
            autoRefreshTimer = null;
            debugLog('Auto-refresh timer stopped');
        }

        if (autoRefreshCountdown) {
            clearInterval(autoRefreshCountdown);
            autoRefreshCountdown = null;
            debugLog('Auto-refresh countdown stopped');
        }

        nextRefreshTime = null;
        updateAutoRefreshUI();
        updateCountdownDisplay();
    }

    /**
     * Toggle auto-refresh on/off
     */
    function toggleAutoRefresh(enabled) {
        const config = window.AUTO_REFRESH_CONFIG;

        // Use provided value or toggle current state
        config.enabled = (enabled !== undefined) ? enabled : !config.enabled;

        // Persist to localStorage
        if (window.setStorageValue) {
            window.setStorageValue('patientListMPage_autoRefreshEnabled', config.enabled);
        }

        debugLog(`Auto-refresh toggled: ${config.enabled}`);

        if (config.enabled) {
            startAutoRefresh();
        } else {
            stopAutoRefresh();
        }
    }

    /**
     * Capture current Handsontable filter state
     */
    function captureFilterState() {
        const app = window.PatientListApp;
        if (!app.state.handsontableInstance) {
            return null;
        }

        const hot = app.state.handsontableInstance;
        const filtersPlugin = hot.getPlugin('filters');
        const sortPlugin = hot.getPlugin('columnSorting');

        let filterConditions = [];
        if (filtersPlugin) {
            try {
                // Use conditionCollection to access internal filter state
                // For each column, get conditions using getConditionAtColumn
                const colCount = hot.countCols();
                for (let col = 0; col < colCount; col++) {
                    const conditions = filtersPlugin.conditionCollection.getConditions(col);
                    if (conditions && conditions.length > 0) {
                        filterConditions.push({
                            column: col,
                            conditions: conditions
                        });
                    }
                }
                debugLog('Filter state captured: ' + filterConditions.length + ' columns filtered', 'debug');
            } catch (error) {
                debugLog('Error capturing filter state: ' + error.message, 'warn');
            }
        }

        let sortConfig = null;
        if (sortPlugin) {
            try {
                sortConfig = sortPlugin.getSortConfig();
                debugLog('Sort state captured', 'debug');
            } catch (error) {
                debugLog('Error capturing sort state: ' + error.message, 'warn');
            }
        }

        const scrollElement = hot.rootElement.querySelector('.ht_master .wtHolder');
        const scrollTop = scrollElement ? scrollElement.scrollTop : 0;

        return {
            filters: filterConditions,
            sorting: sortConfig,
            scrollTop: scrollTop
        };
    }

    /**
     * Restore Handsontable filter state after refresh
     */
    function restoreFilterState(filterState) {
        if (!filterState) {
            debugLog('No filter state to restore');
            return;
        }

        const app = window.PatientListApp;
        if (!app.state.handsontableInstance) {
            debugLog('Cannot restore filters: no table instance', 'warn');
            return;
        }

        const hot = app.state.handsontableInstance;

        // Restore filters
        if (filterState.filters && filterState.filters.length > 0) {
            const filtersPlugin = hot.getPlugin('filters');
            if (filtersPlugin) {
                try {
                    filtersPlugin.clearConditions();

                    // Restore each column's filter conditions
                    filterState.filters.forEach(columnFilter => {
                        const column = columnFilter.column;
                        const conditions = columnFilter.conditions;

                        conditions.forEach(condition => {
                            // addCondition expects: column, conditionObject
                            filtersPlugin.addCondition(column, condition.name, condition.args);
                        });
                    });

                    filtersPlugin.filter();
                    debugLog('✅ Filters restored: ' + filterState.filters.length + ' columns');
                } catch (error) {
                    debugLog('❌ Error restoring filters: ' + error.message, 'error');
                }
            }
        } else {
            debugLog('No filters to restore');
        }

        // Restore sorting
        if (filterState.sorting && filterState.sorting.length > 0) {
            const sortPlugin = hot.getPlugin('columnSorting');
            if (sortPlugin) {
                try {
                    sortPlugin.sort(filterState.sorting);
                    debugLog('✅ Sorting restored');
                } catch (error) {
                    debugLog('❌ Error restoring sort: ' + error.message, 'error');
                }
            }
        }

        // Restore scroll position (slight delay to allow render)
        if (filterState.scrollTop > 0) {
            setTimeout(() => {
                const holder = hot.rootElement.querySelector('.ht_master .wtHolder');
                if (holder) {
                    holder.scrollTop = filterState.scrollTop;
                    debugLog('✅ Scroll position restored');
                }
            }, 100);
        }
    }

    /**
     * Update countdown display
     */
    function updateCountdownDisplay() {
        const countdownSpan = document.getElementById('auto-refresh-countdown');
        if (!countdownSpan) return;

        if (!nextRefreshTime || !window.AUTO_REFRESH_CONFIG.enabled) {
            countdownSpan.textContent = '';
            return;
        }

        const now = Date.now();
        const remaining = Math.max(0, nextRefreshTime - now);
        const minutes = Math.floor(remaining / 60000);
        const seconds = Math.floor((remaining % 60000) / 1000);

        countdownSpan.textContent = `Next: ${minutes}:${seconds.toString().padStart(2, '0')}`;
    }

    /**
     * Update auto-refresh UI indicators
     */
    function updateAutoRefreshUI() {
        const toggleCheckbox = document.getElementById('auto-refresh-toggle');
        const statusSpan = document.getElementById('auto-refresh-status');
        const countdownSpan = document.getElementById('auto-refresh-countdown');

        const enabled = window.AUTO_REFRESH_CONFIG.enabled;

        if (toggleCheckbox) {
            toggleCheckbox.checked = enabled;
        }

        if (statusSpan) {
            statusSpan.textContent = enabled ? 'ON' : 'OFF';
            statusSpan.className = enabled ? 'auto-refresh-status active' : 'auto-refresh-status';
        }

        if (countdownSpan && !enabled) {
            countdownSpan.textContent = '';
        }
    }

    /**
     * Initialize empty table with prompt message (mobility-demo pattern)
     */
    function initializeEmptyTable() {
        // Create message data as object to match expected structure
        const messageData = [{
            PATIENT_NAME: "Select a patient list to fetch and display data",
            UNIT: "",
            ROOM_BED: "",
            AGE: "",
            GENDER: "",
            PATIENT_CLASS: "",
            ADMISSION_DATE: "",
            STATUS: ""
        }];

        // Initialize table with message
        initializePatientTable(messageData);

        // Configure for message display: merge all columns, center text
        if (window.PatientListApp.state.handsontableInstance) {
            window.PatientListApp.state.handsontableInstance.updateSettings({
                mergeCells: [{ row: 0, col: 0, rowspan: 1, colspan: 8 }],  // Merge all 8 columns
                cells: function(row, col) {
                    return {
                        className: 'htCenter htMiddle',  // Center the message
                        renderer: 'text'  // Use plain text renderer (not patientNameRenderer)
                    };
                }
            });
            window.PatientListApp.state.handsontableInstance.render();
            console.log('Empty table initialized with prompt message');
        }
    }

    /**
     * Show message in table (merged cell pattern)
     */
    function showTableMessage(message) {
        const app = window.PatientListApp;

        console.log(`📢 showTableMessage called with: "${message}"`);
        console.log(`📊 Table instance exists: ${!!app.state.handsontableInstance}`);

        if (app.state.handsontableInstance) {
            const messageData = [{
                PATIENT_NAME: message,
                UNIT: "", ROOM_BED: "", AGE: "", GENDER: "",
                PATIENT_CLASS: "", ADMISSION_DATE: "", STATUS: ""
            }];

            console.log(`📊 Setting table data to message:`, messageData);

            app.state.handsontableInstance.updateSettings({
                data: messageData,
                mergeCells: [{ row: 0, col: 0, rowspan: 1, colspan: 8 }],
                cells: function(row, col) {
                    return {
                        className: 'htCenter htMiddle',
                        renderer: 'text'
                    };
                }
            });
            app.state.handsontableInstance.render();

            console.log(`✅ Table updated with message, render() called`);
        } else {
            console.log(`❌ No table instance - message not displayed`);
        }
    }

    /**
     * Clear patient table and show prompt message
     */
    function clearPatientTable() {
        const app = window.PatientListApp;

        if (app.state.handsontableInstance) {
            // Table exists: Show prompt message in merged cell
            const messageData = [{
                PATIENT_NAME: "Select a patient list to fetch and display data",
                UNIT: "",
                ROOM_BED: "",
                AGE: "",
                GENDER: "",
                PATIENT_CLASS: "",
                ADMISSION_DATE: "",
                STATUS: ""
            }];
            app.state.handsontableInstance.updateSettings({
                data: messageData,
                mergeCells: [{ row: 0, col: 0, rowspan: 1, colspan: 8 }],  // Merge all columns
                cells: function(row, col) {
                    return {
                        className: 'htCenter htMiddle',  // Center the message
                        renderer: 'text'  // Use plain text renderer
                    };
                }
            });
            app.state.handsontableInstance.render();
        } else {
            // No table yet: Show message in container
            const container = document.getElementById('patient-table-container');
            if (container) {
                container.innerHTML = '<p id="loading-message" class="font-sans font-normal text-center text-slate-500 italic" style="padding: 2rem;">Select a patient list to fetch and display data</p>';
            }
        }
    }
    
    /**
     * Display message in loading area
     */
    function showMessage(message) {
        const container = document.getElementById('patient-table-container');
        if (container) {
            container.innerHTML = `<p id="loading-message">${message}</p>`;
        }
    }
    
    /**
     * Display initialization error
     */
    function displayInitializationError(error) {
        const container = document.getElementById('patient-table-container');
        if (container) {
            container.innerHTML = `
                <div style="color: red; padding: 20px; border: 1px solid #ccc; margin: 0; margin-top: 16px;">
                    <h3>Initialization Error</h3>
                    <p>Failed to initialize Patient List MPage: ${error.message}</p>
                    <p style="font-size: 0.9em; color: #6b7280;">Check the browser console for more details.</p>
                </div>
            `;
        }
        console.error('Initialization error details:', error);
    }
    
    /**
     * Display general error message
     */
    function displayError(message) {
        showMessage(`<span style="color: red;">Error: ${message}</span>`);
    }
    
    /**
     * Load patient lists into dropdown
     */
    async function loadPatientLists() {
        debugLog('Starting to load patient lists...');
        try {
            const app = window.PatientListApp;
            const patientLists = await app.services.patientList.getPatientLists();
            debugLog('Got patient lists from service:', 'debug', patientLists);
            
            if (patientLists && patientLists.length > 0) {
                const dropdown = document.getElementById('patient-list-select');
                debugLog(`Found dropdown element: ${dropdown ? 'YES' : 'NO'}`);
                
                if (dropdown) {
                    // Clear existing options except first
                    dropdown.innerHTML = '<option value="">Select Patient List...</option>';
                    debugLog(`Cleared dropdown, adding ${patientLists.length} options...`);
                    
                    // Add patient lists to dropdown
                    patientLists.forEach((list, index) => {
                        debugLog(`Processing list ${index}: ID=${list.patientListId}, Name=${list.name}`, 'debug');
                        const option = document.createElement('option');
                        option.value = list.patientListId;
                        option.textContent = list.name;
                        dropdown.appendChild(option);
                        debugLog(`Added list option: ID=${list.patientListId}, Name=${list.name}`);
                    });
                    
                    debugLog(`Dropdown now has ${dropdown.options.length} total options`);
                } else {
                    debugLog('Dropdown element not found during option creation!', 'error');
                }
                
                debugLog(`Loaded ${patientLists.length} patient lists`);
            } else {
                debugLog('No patient lists found', 'warn');
            }
        } catch (error) {
            debugLog('Error loading patient lists: ' + error.message, 'error');
        }
    }
    
    /**
     * Set up event handlers
     */
    function setupEventHandlers() {
        const dropdown = document.getElementById('patient-list-select');
        if (dropdown) {
            dropdown.addEventListener('change', handlePatientListChange);
            debugLog('Event handler attached to dropdown');
        } else {
            debugLog('Dropdown element not found!', 'error');
        }

        // Issue #78: ER Units dropdown event handler
        const erUnitDropdown = document.getElementById('er-unit-select');
        if (erUnitDropdown) {
            erUnitDropdown.addEventListener('change', handleERUnitChange);
            debugLog('Event handler attached to ER unit dropdown');
        } else {
            debugLog('ER unit dropdown element not found!', 'error');
        }

        // Setup refresh button click handler
        const refreshButton = document.getElementById('refresh-data');
        if (refreshButton) {
            refreshButton.addEventListener('click', () => {
                const app = window.PatientListApp;

                // Issue #78: Support refresh for both patient lists AND ER units
                if (app.state.currentListId) {
                    // Refresh patient list
                    debugLog('Refresh button clicked, reloading patient list');
                    debugLog(`Selected patient list ID: ${app.state.currentListId}`);

                    // Capture filter state before manual refresh (Issue #35)
                    const filterState = captureFilterState();

                    // Load data (animation handled in loadPatientData)
                    loadPatientData(app.state.currentListId).then(() => {
                        // Restore filters after manual refresh
                        restoreFilterState(filterState);
                        debugLog('✅ Manual refresh complete, filters restored');
                    });
                } else if (app.state.currentERUnit) {
                    // Refresh ER unit (Issue #78)
                    debugLog('Refresh button clicked, reloading ER unit');
                    debugLog(`Selected ER tracking group: ${app.state.currentERUnit}`);

                    // Capture filter state before manual refresh
                    const filterState = captureFilterState();

                    // Load ER unit data
                    loadERUnitData(app.state.currentERUnit).then(() => {
                        // Restore filters after manual refresh
                        restoreFilterState(filterState);
                        debugLog('✅ Manual ER unit refresh complete, filters restored');
                    });
                } else {
                    debugLog('Refresh clicked but no patient list selected', 'warn');
                }
            });
            debugLog('Event handler attached to refresh button');
        }

        // Setup auto-refresh toggle switch handler (Issue #35, Task 8.3)
        const autoRefreshToggle = document.getElementById('auto-refresh-toggle');
        if (autoRefreshToggle) {
            autoRefreshToggle.addEventListener('change', (event) => {
                debugLog('Auto-refresh toggle changed: ' + event.target.checked);
                toggleAutoRefresh(event.target.checked);
            });
            debugLog('Event handler attached to auto-refresh toggle switch');
        }

        // Filter dropdown event listener (Issue #57 - FirstNet style)
        const patientFilterSelect = document.getElementById('patient-filter-select');
        if (patientFilterSelect) {
            patientFilterSelect.addEventListener('change', (event) => {
                const filterValue = event.target.value;
                debugLog('Patient filter changed to: ' + filterValue);
                // Reload data with new filter
                const currentListId = window.PatientListApp.state.currentListId;
                if (currentListId) {
                    loadPatientData(currentListId);
                }
            });
            debugLog('Event handler attached to patient filter dropdown');
        }

        // Initialize auto-refresh if enabled in config (Issue #35, Task 8.3)
        if (window.AUTO_REFRESH_CONFIG && window.AUTO_REFRESH_CONFIG.enabled) {
            debugLog('Auto-refresh enabled in config, starting service');
            // Delay start slightly to ensure table is loaded
            setTimeout(() => {
                if (window.PatientListApp.state.currentListId) {
                    startAutoRefresh();
                }
            }, 1000);
        }
    }
    
    /**
     * Load patient data for a given patient list ID
     * Reusable function for both dropdown selection and refresh button
     */
    async function loadPatientData(patientListId) {
        const app = window.PatientListApp;

        debugLog('Loading patients for list: ' + patientListId);

        // Start refresh animation
        const refreshButton = document.getElementById('refresh-data');
        if (refreshButton) {
            refreshButton.classList.add('refreshing');
            disableRefreshButton();
        }

        // Show loading message in table
        if (app.state.handsontableInstance) {
            console.log('Showing loading message in table...');
            showTableMessage('Loading patient data...');
        } else {
            // No table yet: Show loading message in container
            const container = document.getElementById('patient-table-container');
            if (container) {
                container.innerHTML = '<p id="loading-message" class="font-sans font-normal text-center text-slate-500 italic" style="padding: 2rem;">Loading patient data...</p>';
            }
        }

        try {

            // Get patients for selected list
            const rawPatientData = await app.services.patientList.getPatientListPatients(patientListId);

            if (rawPatientData && rawPatientData.length > 0) {
                // Process data through PatientDataService to ensure STATUS and ACUITY are included
                const processedData = app.services.patientData.formatForTable(rawPatientData);

                debugLog('Raw patient data:', 'debug', rawPatientData);
                debugLog('Processed patient data:', 'debug', processedData);

                // Apply filters before displaying (Issue #57)
                const filteredData = applyPatientFilters(processedData);
                debugLog('Filtered patient data:', 'debug', filteredData);

                initializePatientTable(filteredData);
            } else {
                showTableMessage('No patients found for selected list');
            }
        } catch (error) {
            // Suppress Firebug Lite strict mode inspection errors for end users
            if (error.message && error.message.includes('strict mode functions')) {
                debugLog('Firebug Lite strict mode inspection (suppressed for end users)', 'debug');
                // Try again without the error-causing inspection
                try {
                    const rawPatientData = await app.services.patientList.getPatientListPatients(patientListId);
                    if (rawPatientData && rawPatientData.length > 0) {
                        const processedData = app.services.patientData.formatForTable(rawPatientData);
                        initializePatientTable(processedData);
                    }
                } catch (retryError) {
                    debugLog('Error on retry: ' + retryError.message, 'error');
                    showTableMessage('Error loading patient data. Please try again.');
                }
            } else {
                debugLog('Error loading patient data: ' + error.message, 'error');
                showTableMessage('Error loading patient data. Please try again.');
            }
        } finally {
            // Always stop refresh animation, even on error
            if (refreshButton) {
                refreshButton.classList.remove('refreshing');
                enableRefreshButton();
            }
        }
    }

    /**
     * Handle patient list selection change
     */
    async function handlePatientListChange(event) {
        const selectedListId = event.target.value;
        const app = window.PatientListApp;

        debugLog('Event triggered with selectedListId: ' + selectedListId + ' (type: ' + typeof selectedListId + ')');

        // Prevent loading with undefined/null/empty values
        if (!selectedListId || selectedListId === 'undefined' || selectedListId === 'null') {
            clearPatientTable();
            app.state.currentListId = null;
            return;
        }

        // Issue #78: Clear ER unit selection (mutual exclusion)
        const erUnitDropdown = document.getElementById('er-unit-select');
        if (erUnitDropdown) {
            erUnitDropdown.value = '';
        }

        // Store selected list ID and load data
        app.state.currentListId = selectedListId;
        app.state.currentERUnit = null;
        await loadPatientData(selectedListId);
    }

    /**
     * Handle ER unit selection change (Issue #78)
     */
    async function handleERUnitChange(event) {
        const selectedTrackingGroup = event.target.value;
        const app = window.PatientListApp;

        debugLog('ER Unit changed: ' + selectedTrackingGroup);

        // Prevent loading with undefined/null/empty values
        if (!selectedTrackingGroup || selectedTrackingGroup === 'undefined' || selectedTrackingGroup === 'null') {
            clearPatientTable();
            app.state.currentERUnit = null;
            return;
        }

        // Clear patient list selection (mutual exclusion)
        const patientListDropdown = document.getElementById('patient-list-select');
        if (patientListDropdown) {
            patientListDropdown.value = '';
        }

        // Store selected ER unit and load data
        app.state.currentERUnit = selectedTrackingGroup;
        app.state.currentListId = null;
        await loadERUnitData(selectedTrackingGroup);
    }

    /**
     * Load ER unit patients (Issue #78)
     */
    async function loadERUnitData(trackingGroupCd) {
        const app = window.PatientListApp;
        const refreshButton = document.getElementById('refresh-data');

        try {
            // Start refresh animation (Issue #78: same as patient list)
            if (refreshButton) {
                refreshButton.classList.add('refreshing');
                disableRefreshButton();
            }

            // Clear patient stats indicator (Issue #78: clear counts during load)
            const statsIndicator = document.getElementById('patient-stats-indicator');
            if (statsIndicator) {
                statsIndicator.textContent = '';
            }

            // Show loading message in table
            if (app.state.handsontableInstance) {
                console.log('Showing ER loading message in table...');
                showTableMessage('Loading ER unit patient data...');
            } else {
                // No table yet: Show loading message in container
                const container = document.getElementById('patient-table-container');
                if (container) {
                    container.innerHTML = '<p id="loading-message" class="font-sans font-normal text-center text-slate-500 italic" style="padding: 2rem;">Loading ER unit patient data...</p>';
                }
            }

            debugLog('Loading ER unit patients for tracking group: ' + trackingGroupCd);

            // Call service to get ER patients
            const patients = await app.services.patientList.getERUnitPatients(trackingGroupCd);

            debugLog('Got ' + patients.length + ' patients for ER tracking group ' + trackingGroupCd);

            if (patients && patients.length > 0) {
                // Process data through PatientDataService (same as patient list)
                const processedData = app.services.patientData.formatForTable(patients);
                debugLog('Processed ER patient data');

                // Apply filters before displaying
                const filteredData = applyPatientFilters(processedData);
                debugLog('Filtered ER patient data: ' + filteredData.length + ' patients');

                // Display in table
                initializePatientTable(filteredData);
            } else {
                showTableMessage('No patients found for selected ER unit');
            }

        } catch (error) {
            debugLog('Error loading ER unit data: ' + error.message, 'error');
            showTableMessage('Error loading ER unit data. Please try again.');
        } finally {
            // Always stop refresh animation, even on error (Issue #78)
            if (refreshButton) {
                refreshButton.classList.remove('refreshing');
                enableRefreshButton();
            }
        }
    }

    /**
     * Show loading message
     */
    function showLoadingMessage() {
        const loadingMsg = document.getElementById('loading-message');
        if (loadingMsg) {
            loadingMsg.textContent = 'Loading patient data...';
        }
    }
    
    /**
     * Show message in container
     */
    function showMessage(message) {
        const container = document.getElementById('patient-table-container');
        const app = window.PatientListApp;

        if (app.state.handsontableInstance) {
            // Table exists: Clear data but keep visible
            app.state.handsontableInstance.updateSettings({ data: [[]] });
            app.state.handsontableInstance.render();
        }

        if (container) {
            container.innerHTML = `<p id="loading-message" class="font-sans font-normal text-center text-slate-500 italic" style="padding: 2rem;">${message}</p>`;
        }
    }
    
    /**
     * Clear patient table
     */
    // REMOVED: Duplicate clearPatientTable function (using single definition above)

    // Expose functions to global scope for HTML onclick handlers and Config.js
    window.initializeServices = initializeServices;
    window.displayInitializationError = displayInitializationError;
    window.loadPatientLists = loadPatientLists;
    window.clearPatientTable = clearPatientTable;
    
    // Auto-initialize if services are ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            // Services will be initialized by the init() function in HTML
        });
    }
    
})(window);