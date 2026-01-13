/**
 * IView Launcher - TASKDOC Integration
 *
 * Launches Cerner Interactive View (iView) from dashboard to specific band/section
 * Uses TASKDOC DiscernObjectFactory pattern
 *
 * @version 1.0.1
 * @date 2026-01-12
 * @github-issue #20 (Task 20 - Links to iView/Documentation)
 *
 * Reference: MPages Wiki - LaunchIView
 * Syntax: taskObject.LaunchIView(bandName, sectionName, eventSetName, patientId, encounterId)
 */

// DEBUG: Immediate log before IIFE to confirm script is loading
console.log('📊 [DEBUG] IViewLauncher.js script starting to load...');

(function(window) {
    console.log('📊 [DEBUG] IViewLauncher IIFE executing...');
    'use strict';

    /**
     * iView Configuration - Band/Section mappings for clinical events
     *
     * IMPORTANT (per uCern research):
     * - Band name is auto-converted to lowercase by launchIView()
     * - Section name must match EXACTLY as shown in iView UI
     * - EventSet can be empty string '' (works per uCern thread)
     *
     * To find band names: Run CCL query on PREFDIR_GROUP/PREFDIR_DISPLAYNAME
     * To find section names: Open iView in PowerChart and note exact names
     */
    const IVIEW_CONFIG = {
        // Band name from PREFDIR query: "Adult Systems Assessment"
        // (will be auto-converted to lowercase: "adult systems assessment")
        defaultBand: 'Adult Systems Assessment',

        // Section mappings for each clinical event metric
        sections: {
            // Morse Fall Risk Score - visible in screenshot as "Morse Fall Scale"
            morse: {
                band: 'Adult Systems Assessment',
                section: 'Morse Fall Scale',  // Must match iView UI exactly
                eventSet: ''  // Empty string works per uCern
            },

            // BMAT - visible in screenshot
            bmat: {
                band: 'Adult Systems Assessment',
                section: 'BMAT',  // Must match iView UI exactly
                eventSet: ''  // Empty string works per uCern
            },

            // Baseline Mobility - PLACEHOLDER (update after checking PowerChart)
            baseline: {
                band: 'Adult Systems Assessment',
                section: 'PLACEHOLDER_BASELINE',  // TODO: Find correct section name
                eventSet: ''
            },

            // Toileting Method - PLACEHOLDER (update after checking PowerChart)
            toileting: {
                band: 'Adult Systems Assessment',
                section: 'PLACEHOLDER_TOILETING',  // TODO: Find correct section name
                eventSet: ''
            },

            // Ambulation Distance - PLACEHOLDER (update after checking PowerChart)
            ambulation: {
                band: 'Adult Systems Assessment',
                section: 'PLACEHOLDER_AMBULATION',  // TODO: Find correct section name
                eventSet: ''
            },

            // PT Transfer - PLACEHOLDER (may be in different band - Rehab?)
            pt_transfer: {
                band: 'Adult Systems Assessment',
                section: 'PLACEHOLDER_PT',  // TODO: Find correct section name
                eventSet: ''
            },

            // OT Transfer - PLACEHOLDER (may be in different band - Rehab?)
            ot_transfer: {
                band: 'Adult Systems Assessment',
                section: 'PLACEHOLDER_OT',  // TODO: Find correct section name
                eventSet: ''
            }
        }
    };

    /**
     * Launch iView to a specific band/section
     *
     * @param {string} bandName - IView Band Name
     * @param {string} sectionName - Section Name within the band
     * @param {string} eventSetName - Event Set Name
     * @param {number} personId - Patient person_id
     * @param {number} encntrId - Patient encntr_id
     */
    function launchIView(bandName, sectionName, eventSetName, personId, encntrId) {
        // Per uCern research: band name MUST be lowercase, eventSetName can be empty
        // Section name must match exactly as shown in iView UI
        const bandNameLower = bandName.toLowerCase();
        const effectiveEventSet = eventSetName || '';  // Empty string works per uCern

        console.log('📊 LAUNCHING IVIEW via TASKDOC');
        console.log('📊 Band (original):', bandName);
        console.log('📊 Band (lowercase):', bandNameLower);
        console.log('📊 Section:', sectionName);
        console.log('📊 Event Set:', effectiveEventSet || '(empty)');
        console.log('📊 Person ID:', personId);
        console.log('📊 Encounter ID:', encntrId);

        // Check if DiscernObjectFactory is available (PowerChart environment)
        if (window.external && typeof window.external.DiscernObjectFactory === 'function') {
            try {
                console.log('📊 DiscernObjectFactory available - creating TASKDOC object');
                const taskObject = window.external.DiscernObjectFactory("TASKDOC");

                console.log('📊 Launching iView with lowercase band...');
                taskObject.LaunchIView(bandNameLower, sectionName, effectiveEventSet, personId, encntrId);
                console.log('📊 iView launch initiated');
            } catch (error) {
                console.error('📊 Error launching iView:', error);
                alert(`Error launching iView:\n${error.message}\n\nPlease try again or navigate manually.`);
            }
        } else {
            console.warn('📊 DiscernObjectFactory not available (not in PowerChart environment)');
            console.log('📊 POC Mode: Would launch iView with:', { bandNameLower, sectionName, effectiveEventSet, personId, encntrId });
            alert(`POC Mode: Would launch iView\n\nBand: ${bandNameLower}\nSection: ${sectionName}\nEvent Set: ${effectiveEventSet || '(empty)'}\nPerson ID: ${personId}\nEncounter ID: ${encntrId}\n\n(iView launch only works in Cerner PowerChart environment)`);
        }
    }

    /**
     * Launch iView for a specific metric key
     *
     * @param {string} metricKey - Metric identifier (e.g., 'morse', 'bmat', 'ambulation')
     * @param {number} personId - Patient person_id
     * @param {number} encntrId - Patient encntr_id
     */
    function launchIViewForMetric(metricKey, personId, encntrId) {
        const config = IVIEW_CONFIG.sections[metricKey];

        if (!config) {
            console.warn(`📊 No iView configuration found for metric: ${metricKey}`);
            alert(`iView navigation not configured for: ${metricKey}`);
            return;
        }

        // Check for placeholder sections
        if (config.section.startsWith('PLACEHOLDER_')) {
            console.warn(`📊 iView section not configured for metric: ${metricKey}`);
            alert(`iView section not yet configured for: ${metricKey}\n\nPlease update IVIEW_CONFIG in IViewLauncher.js with the correct section name from PowerChart.`);
            return;
        }

        launchIView(config.band, config.section, config.eventSet, personId, encntrId);
    }

    /**
     * Get iView configuration for a metric
     *
     * @param {string} metricKey - Metric identifier
     * @returns {Object|null} Configuration object or null if not found
     */
    function getIViewConfig(metricKey) {
        return IVIEW_CONFIG.sections[metricKey] || null;
    }

    /**
     * Check if iView is configured for a metric
     *
     * @param {string} metricKey - Metric identifier
     * @returns {boolean} True if properly configured (not placeholder)
     */
    function isIViewConfigured(metricKey) {
        const config = IVIEW_CONFIG.sections[metricKey];
        return config && !config.section.startsWith('PLACEHOLDER_');
    }

    // Expose functions globally
    window.IViewLauncher = {
        launchIView: launchIView,
        launchIViewForMetric: launchIViewForMetric,
        getIViewConfig: getIViewConfig,
        isIViewConfigured: isIViewConfigured,
        config: IVIEW_CONFIG
    };

    console.log('📊 IViewLauncher initialized');
    console.log('📊 Configured metrics:', Object.keys(IVIEW_CONFIG.sections).filter(k => isIViewConfigured(k)));
    console.log('📊 Placeholder metrics:', Object.keys(IVIEW_CONFIG.sections).filter(k => !isIViewConfigured(k)));
    console.log('📊 [DEBUG] window.IViewLauncher exists:', !!window.IViewLauncher);
    console.log('📊 [DEBUG] isIViewConfigured function exists:', typeof window.IViewLauncher?.isIViewConfigured);

})(window);

// DEBUG: Final confirmation after IIFE
console.log('📊 [DEBUG] IViewLauncher.js script finished loading');
console.log('📊 [DEBUG] Final check - window.IViewLauncher:', window.IViewLauncher);
