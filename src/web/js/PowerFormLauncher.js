/**
 * PowerForm Launcher - MPAGES_EVENT Integration
 *
 * Launches Cerner PowerForms from dashboard using MPAGES_EVENT
 *
 * @version 1.0.0
 * @date 2025-10-18
 * @github-issue #28
 */

(function(window) {
    'use strict';

    /**
     * Launch a PowerForm using MPAGES_EVENT
     *
     * @param {number} personId - Patient person_id
     * @param {number} encntrId - Patient encntr_id
     * @param {number} formId - PowerForm form_id from DCP_FORMS_REF table (0 for Ad Hoc or use activityId)
     * @param {number} activityId - PowerForm activity_id from DCP_FORMS_ACTIVITY table (0 to use formId)
     * @param {number} chartMode - 0 = edit mode, 1 = view-only mode
     *
     * MPAGES_EVENT Parameters (pipe-delimited):
     * personId|encntrId|formId|activityId|chartMode
     */
    function launchPowerForm(personId, encntrId, formId, activityId, chartMode) {
        // Default parameters
        activityId = activityId || 0;
        chartMode = chartMode || 0; // Default to edit mode

        // Construct pipe-delimited parameter string
        const params = `${personId}|${encntrId}|${formId}|${activityId}|${chartMode}`;

        console.log('📋 LAUNCHING POWERFORM via MPAGES_EVENT');
        console.log('📋 Person ID:', personId);
        console.log('📋 Encounter ID:', encntrId);
        console.log('📋 Form ID:', formId);
        console.log('📋 Activity ID:', activityId);
        console.log('📋 Chart Mode:', chartMode, '(0=edit, 1=view-only)');
        console.log('📋 Parameters:', params);

        // Check if MPAGES_EVENT is available (PowerChart environment)
        if (typeof MPAGES_EVENT === 'function') {
            console.log('📋 MPAGES_EVENT available - launching PowerForm');
            MPAGES_EVENT("POWERFORM", params);
        } else {
            console.warn('📋 MPAGES_EVENT not available (not in PowerChart environment)');
            console.log('📋 POC Mode: Would launch PowerForm with params:', params);
            alert(`POC Mode: Would launch PowerForm\n\nPerson ID: ${personId}\nEncounter ID: ${encntrId}\nForm ID: ${formId}\n\n(PowerForm launch only works in Cerner PowerChart environment)`);
        }
    }

    /**
     * Launch Sepsis Screening PowerForm
     *
     * PowerForm: "Severe Sepsis/Septic Shock Rule"
     * Form ID: 5028848557 (from DCP_FORMS_REF table)
     *
     * @param {number} personId - Patient person_id
     * @param {number} encntrId - Patient encntr_id
     */
    function launchSepsisScreening(personId, encntrId) {
        const SEPSIS_SCREENING_FORM_ID = 5028848557; // Severe Sepsis/Septic Shock Rule
        console.log('📋 Launching Sepsis Screening PowerForm (ID: ' + SEPSIS_SCREENING_FORM_ID + ')');
        launchPowerForm(personId, encntrId, SEPSIS_SCREENING_FORM_ID, 0, 0); // Edit mode, no activity
    }

    /**
     * Launch Perfusion Assessment PowerForm
     *
     * PowerForm: "QM Septic Shock Assessment"
     * Form ID: 2504884177 (DCP_FORMS_REF_ID from CERT - Issue #47)
     *
     * @param {number} personId - Patient person_id
     * @param {number} encntrId - Patient encntr_id
     */
    function launchPerfusionAssessment(personId, encntrId) {
        const PERFUSION_FORM_ID = 2504884177; // QM Septic Shock Assessment (corrected - Issue #47)
        console.log('💓 Launching Perfusion Assessment PowerForm (ID: ' + PERFUSION_FORM_ID + ')');
        launchPowerForm(personId, encntrId, PERFUSION_FORM_ID, 0, 0); // Edit mode, no activity
    }

    // Expose functions globally
    window.PowerFormLauncher = {
        launchPowerForm: launchPowerForm,
        launchSepsisScreening: launchSepsisScreening,
        launchPerfusionAssessment: launchPerfusionAssessment
    };

    console.log('📋 PowerFormLauncher initialized');

})(window);
