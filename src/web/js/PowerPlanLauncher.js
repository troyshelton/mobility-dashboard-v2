// PowerPlanLauncher.js - PowerPlan Quick Launch POC (Issue #29, Task 4)
// Uses Cerner DiscernObjectFactory MOEW API to launch PowerPlan ordering dialog
//
// CRITICAL IMPLEMENTATION NOTES FOR EDGE CHROMIUM:
// ================================================
//
// 1. ASYNC/AWAIT REQUIRED (Edge Chromium):
//    - All MOEW API calls MUST use async/await pattern
//    - Internet Explorer used synchronous calls, Edge Chromium uses Promises
//    - Reference: https://community.oracle.com/oraclehealth/discussion/comment/1719361#Comment_1719361
//
// 2. CORRECT CALL SEQUENCE:
//    const PowerOrdersMPageUtils = await window.external.DiscernObjectFactory("POWERORDERS");
//    m_hMOEW = await PowerOrdersMPageUtils.CreateMOEW(personId, encounterId, 24, 2, 127);
//    await PowerOrdersMPageUtils.CustomizeTabMOEW(m_hMOEW, 2, 127);
//    await PowerOrdersMPageUtils.CustomizeTabMOEW(m_hMOEW, 3, 127);
//    await PowerOrdersMPageUtils.AddPowerPlanMOEW(m_hMOEW, catalogId, 0.00);
//    PowerOrdersMPageUtils.DisplayMOEW(m_hMOEW); // Don't await - returns immediately
//
// 3. KEY DIFFERENCES FROM IE:
//    - Must use 'var' or 'const/let' (both work with async)
//    - Must be inside async function to use await
//    - DisplayMOEW returns immediately, dialog appears asynchronously
//    - DestroyMOEW handled automatically by PowerChart (don't call manually)
//
// 4. LOADING INDICATOR TIMING:
//    - Remove loading overlay BEFORE calling DisplayMOEW
//    - Ordering physician dialog appears first (for non-providers)
//    - MOEW dialog appears after physician is selected
//    - If overlay stays visible, it blocks the ordering physician dialog
//
// 5. TESTED ENVIRONMENT:
//    - FirstNet Organizer (Edge Chromium embedded)
//    - Multi-patient list context (organizer view)
//    - CERT deployment
//    - Verified: 2025-10-19
//
// Official Wiki References:
// - POWERORDERS: https://wiki.cerner.com/display/public/MPDEVWIKI/POWERORDERS
// - AddPowerPlanMOEW: https://wiki.cerner.com/display/public/MPDEVWIKI/AddPowerPlanMOEW
// - Edge Chromium: https://wiki.cerner.com/display/public/MPDEVWIKI/Understand+MPages+with+Microsoft+Edge
//
// UCRN Forum Solution (Critical for Edge Chromium):
// https://community.oracle.com/oraclehealth/discussion/comment/1719361#Comment_1719361
// Credit: Chris Goepfrich (Oracle Community Champion) - async/await pattern

(function(window) {
    'use strict';

    /**
     * PowerPlanLauncher - Launches PowerPlan ordering dialog using MOEW API
     *
     * MOEW (Multiple Order Entry Wrapper) API allows programmatic launching
     * of PowerChart ordering dialogs with patient context pre-populated.
     *
     * IMPORTANT: Edge Chromium requires async/await for all MOEW calls.
     * See header comments for complete implementation details.
     */
    function PowerPlanLauncher() {
        // ED Sepsis PowerPlan parent catalog group ID (provided by stakeholder)
        // P_CAT_GROUP_ID: 10770752899.0 (parent PowerPlan, not sub-phase)
        this.SEPSIS_POWERPLAN_CATALOG_ID = 10770752899.0;

        // Abbreviated order set catalog ID (Issue #37)
        // P_CAT_GROUP_ID: 10770754745 (Blood Cultures + Antibiotics only)
        this.ABBREVIATED_SEPSIS_CATALOG_ID = 10770754745;

        this.debugMode = true;
    }

    /**
     * Launch PowerPlan ordering dialog for a patient
     *
     * @param {Object} patientData - Patient data from dashboard row
     * @param {Number} patientData.PERSON_ID - Patient person ID
     * @param {Number} patientData.ENCNTR_ID - Encounter ID
     * @param {String} patientData.PATIENT_NAME - Patient name (for logging)
     * @returns {Promise} - Resolves when MOEW dialog is launched
     */
    PowerPlanLauncher.prototype.launchPowerPlan = async function(patientData) {
        try {
            if (this.debugMode) {
                console.log('[PowerPlanLauncher] Launching PowerPlan for:', {
                    patient: patientData.PATIENT_NAME,
                    personId: patientData.PERSON_ID,
                    encounterId: patientData.ENCNTR_ID,
                    catalogId: this.SEPSIS_POWERPLAN_CATALOG_ID
                });
            }

            // Validate required patient context
            if (!patientData.PERSON_ID || !patientData.ENCNTR_ID) {
                throw new Error('Missing required patient context (PERSON_ID or ENCNTR_ID)');
            }

            // Check if running in PowerChart environment
            if (typeof window.external === 'undefined' || typeof window.external.DiscernObjectFactory === 'undefined') {
                console.warn('[PowerPlanLauncher] DiscernObjectFactory not available - running in test/dev mode');
                this._showTestModeDialog(patientData);
                return { success: true, testMode: true };
            }

            // MOEW API Implementation for Edge Chromium (async/await pattern)
            // Based on UCRN forum solution: All MOEW calls must be awaited!
            if (this.debugMode) {
                console.log('[PowerPlanLauncher] Launching PowerPlan with async MOEW API...');
                console.log('[PowerPlanLauncher] Person ID:', patientData.PERSON_ID);
                console.log('[PowerPlanLauncher] Encounter ID:', patientData.ENCNTR_ID);
                console.log('[PowerPlanLauncher] Catalog ID:', this.SEPSIS_POWERPLAN_CATALOG_ID);
            }

            let m_hMOEW = 0;

            // Step 1: Create POWERORDERS object (await in Edge Chromium)
            const PowerOrdersMPageUtils = await window.external.DiscernObjectFactory("POWERORDERS");

            // Step 2: Create MOEW with patient context (await!)
            m_hMOEW = await PowerOrdersMPageUtils.CreateMOEW(
                patientData.PERSON_ID,
                patientData.ENCNTR_ID,
                24,
                2,
                127
            );

            if (this.debugMode) {
                console.log('[PowerPlanLauncher] MOEW handle created:', m_hMOEW);
            }

            // Step 3: Customize MOEW tabs (await!)
            await PowerOrdersMPageUtils.CustomizeTabMOEW(m_hMOEW, 2, 127);
            await PowerOrdersMPageUtils.CustomizeTabMOEW(m_hMOEW, 3, 127);

            if (this.debugMode) {
                console.log('[PowerPlanLauncher] MOEW tabs customized');
            }

            // Step 4: Add PowerPlan to MOEW (await!)
            await PowerOrdersMPageUtils.AddPowerPlanMOEW(
                m_hMOEW,
                this.SEPSIS_POWERPLAN_CATALOG_ID,
                0.00
            );

            if (this.debugMode) {
                console.log('[PowerPlanLauncher] PowerPlan added to MOEW - ready to display');
            }

            // Step 5: Display MOEW (don't await - let it happen in background)
            // This triggers ordering physician dialog, then MOEW
            PowerOrdersMPageUtils.DisplayMOEW(m_hMOEW);

            if (this.debugMode) {
                console.log('[PowerPlanLauncher] DisplayMOEW called - dialogs will appear');
            }

            // Return immediately so loading overlay can be removed
            // This allows the ordering physician dialog to appear without overlay blocking it
            // Note: DestroyMOEW should be called after user closes dialog,
            // but for now we let PowerChart handle cleanup automatically
            return {
                success: true,
                testMode: false,
                catalogId: this.SEPSIS_POWERPLAN_CATALOG_ID,
                personId: patientData.PERSON_ID,
                encounterId: patientData.ENCNTR_ID
            };

        } catch (error) {
            console.error('[PowerPlanLauncher] Error launching PowerPlan:', error);
            throw error;
        }
    };

    /**
     * Show test mode dialog when DiscernObjectFactory is not available
     * (Dev/local testing environment)
     *
     * @private
     */
    PowerPlanLauncher.prototype._showTestModeDialog = function(patientData) {
        const message = `PowerPlan Quick Launch - TEST MODE

Patient: ${patientData.PATIENT_NAME}
Person ID: ${patientData.PERSON_ID}
Encounter ID: ${patientData.ENCNTR_ID}

PowerPlan: ED Sepsis Protocol
Catalog ID: ${this.SEPSIS_POWERPLAN_CATALOG_ID}

ℹ️ In CERT/Production, this would launch the PowerPlan ordering dialog.

MOEW API calls that would execute:
1. PowerOrdersMPageUtils = window.external.DiscernObjectFactory("POWERORDERS")
2. m_hMOEW = PowerOrdersMPageUtils.CreateMOEW(${patientData.PERSON_ID}, ${patientData.ENCNTR_ID}, 24, 2, 127)
3. PowerOrdersMPageUtils.AddPowerPlanMOEW(m_hMOEW, ${this.SEPSIS_POWERPLAN_CATALOG_ID}, 0.00)
4. PowerOrdersMPageUtils.DisplayMOEW(m_hMOEW)`;

        alert(message);
    };

    /**
     * Launch abbreviated order set (Blood Cultures + Antibiotics only) for a patient (Issue #37)
     * Faster workflow when only blood cultures and antibiotics are missing
     *
     * @param {Number} personId - Patient person ID
     * @param {Number} encntrId - Encounter ID
     * @param {String} patientName - Patient name (for logging)
     * @returns {Promise} - Resolves when MOEW dialog is launched
     */
    PowerPlanLauncher.prototype.launchAbbreviatedSepsisOrders = async function(personId, encntrId, patientName) {
        try {
            if (this.debugMode) {
                console.log('[PowerPlanLauncher] Launching Abbreviated Sepsis Orders (Blood Cultures + Antibiotics) for:', {
                    patient: patientName,
                    personId: personId,
                    encounterId: encntrId,
                    catalogId: this.ABBREVIATED_SEPSIS_CATALOG_ID
                });
            }

            // Validate required patient context
            if (!personId || !encntrId) {
                throw new Error('Missing required patient context (personId or encntrId)');
            }

            // Check if running in PowerChart environment
            if (typeof window.external === 'undefined' || typeof window.external.DiscernObjectFactory === 'undefined') {
                console.warn('[PowerPlanLauncher] DiscernObjectFactory not available - running in test/dev mode');
                this._showAbbreviatedTestModeDialog(personId, encntrId, patientName);
                return { success: true, testMode: true };
            }

            // MOEW API Implementation for Edge Chromium (async/await pattern)
            if (this.debugMode) {
                console.log('[PowerPlanLauncher] Launching abbreviated order set with async MOEW API...');
            }

            let m_hMOEW = 0;

            // Step 1: Create POWERORDERS object
            const PowerOrdersMPageUtils = await window.external.DiscernObjectFactory("POWERORDERS");

            // Step 2: Create MOEW with patient context
            m_hMOEW = await PowerOrdersMPageUtils.CreateMOEW(personId, encntrId, 24, 2, 127);

            if (this.debugMode) {
                console.log('[PowerPlanLauncher] MOEW handle created:', m_hMOEW);
            }

            // Step 3: Customize MOEW tabs
            await PowerOrdersMPageUtils.CustomizeTabMOEW(m_hMOEW, 2, 127);
            await PowerOrdersMPageUtils.CustomizeTabMOEW(m_hMOEW, 3, 127);

            // Step 4: Add abbreviated order set to MOEW
            await PowerOrdersMPageUtils.AddPowerPlanMOEW(
                m_hMOEW,
                this.ABBREVIATED_SEPSIS_CATALOG_ID,
                0.00
            );

            if (this.debugMode) {
                console.log('[PowerPlanLauncher] Abbreviated order set added to MOEW - ready to display');
            }

            // Step 5: Display MOEW (ordering physician dialog → MOEW)
            PowerOrdersMPageUtils.DisplayMOEW(m_hMOEW);

            if (this.debugMode) {
                console.log('[PowerPlanLauncher] DisplayMOEW called - abbreviated order set will appear');
            }

            return {
                success: true,
                testMode: false,
                catalogId: this.ABBREVIATED_SEPSIS_CATALOG_ID,
                personId: personId,
                encounterId: encntrId
            };

        } catch (error) {
            console.error('[PowerPlanLauncher] Error launching abbreviated order set:', error);
            throw error;
        }
    };

    /**
     * Show test mode dialog for abbreviated order set
     * @private
     */
    PowerPlanLauncher.prototype._showAbbreviatedTestModeDialog = function(personId, encntrId, patientName) {
        const message = `Abbreviated Sepsis Orders Quick Launch - TEST MODE

Patient: ${patientName}
Person ID: ${personId}
Encounter ID: ${encntrId}

Order Set: ED Severe Sepsis Resuscitation/Antibiotics - ADULT
Catalog ID: ${this.ABBREVIATED_SEPSIS_CATALOG_ID}
Contains: Blood Cultures + Antibiotics (NOT full PowerPlan)

ℹ️ In CERT/Production, this would launch the abbreviated order set dialog.

MOEW API calls that would execute:
1. PowerOrdersMPageUtils = window.external.DiscernObjectFactory("POWERORDERS")
2. m_hMOEW = PowerOrdersMPageUtils.CreateMOEW(${personId}, ${encntrId}, 24, 2, 127)
3. PowerOrdersMPageUtils.AddPowerPlanMOEW(m_hMOEW, ${this.ABBREVIATED_SEPSIS_CATALOG_ID}, 0.00)
4. PowerOrdersMPageUtils.DisplayMOEW(m_hMOEW)`;

        alert(message);
    };

    /**
     * Get PowerPlan catalog ID (for debugging/verification)
     */
    PowerPlanLauncher.prototype.getCatalogId = function() {
        return this.SEPSIS_POWERPLAN_CATALOG_ID;
    };

    /**
     * Get abbreviated order set catalog ID (for debugging/verification)
     */
    PowerPlanLauncher.prototype.getAbbreviatedCatalogId = function() {
        return this.ABBREVIATED_SEPSIS_CATALOG_ID;
    };

    // Export to global scope
    window.PowerPlanLauncher = PowerPlanLauncher;

    // Verify script loaded
    console.log('[PowerPlanLauncher] Service loaded successfully - window.PowerPlanLauncher available');

})(window);
