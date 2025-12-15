// Visual Indicators and UI Management for Patient List MPage Template
(function(window) {
    'use strict';
    
    /**
     * localStorage utilities with error handling
     */
    function getStorageValue(key, defaultValue) {
        try {
            const stored = localStorage.getItem(key);
            console.log(`[VisualIndicators] localStorage.getItem('${key}') = '${stored}'`);
            
            if (stored === null) {
                console.log(`[VisualIndicators] No stored value found for '${key}', using default: ${defaultValue}`);
                return defaultValue;
            }
            
            // Parse boolean values
            if (stored === 'true') return true;
            if (stored === 'false') return false;
            
            // Parse numbers  
            if (!isNaN(stored) && stored !== '') {
                return parseFloat(stored);
            }
            
            // Return string as-is
            console.log(`[VisualIndicators] Using stored string value for '${key}': '${stored}'`);
            return stored;
            
        } catch (error) {
            console.warn(`[VisualIndicators] localStorage error for '${key}':`, error.message);
            console.log(`[VisualIndicators] Falling back to default value: ${defaultValue}`);
            return defaultValue;
        }
    }
    
    function setStorageValue(key, value) {
        try {
            const stringValue = String(value);
            localStorage.setItem(key, stringValue);
            console.log(`[VisualIndicators] localStorage.setItem('${key}', '${stringValue}') - SUCCESS`);
            return true;
        } catch (error) {
            console.error(`[VisualIndicators] localStorage.setItem('${key}') FAILED:`, error.message);
            console.warn(`[VisualIndicators] localStorage may not be available in this environment`);
            return false;
        }
    }

    /**
     * Reload patient lists with current configuration
     */
    function reloadPatientLists() {
        try {
            // Check if PatientListApp is available
            if (window.PatientListApp && window.PatientListApp.services && window.PatientListApp.services.patientList) {
                console.log('[VisualIndicators] Attempting to reload patient lists...');
                
                // Clear current table
                if (window.clearPatientTable && typeof window.clearPatientTable === 'function') {
                    window.clearPatientTable();
                }
                
                // Reload patient lists using main app function
                if (window.loadPatientLists && typeof window.loadPatientLists === 'function') {
                    window.loadPatientLists();
                } else {
                    console.warn('[VisualIndicators] loadPatientLists function not available globally');
                    console.log('[VisualIndicators] Please refresh page for configuration to take full effect');
                }
            } else {
                console.warn('[VisualIndicators] PatientListApp not fully initialized yet');
                console.log('[VisualIndicators] Configuration change will take effect on next patient list load');
            }
        } catch (error) {
            console.error('[VisualIndicators] Error reloading patient lists:', error.message);
            console.log('[VisualIndicators] Please refresh page for configuration to take full effect');
        }
    }

    /**
     * Unified visual indicator for all active modes
     */
    function updateUnifiedIndicator() {
        // Remove any existing indicators
        removeOldIndicators();
        
        const isSimulator = window.SIMULATOR_CONFIG?.enabled;
        const impersonateId = window.USER_CONTEXT_CONFIG?.impersonatePersonId;
        
        // Build status message based on active modes
        let message = '';
        let backgroundColor = '#333333'; // Default gray
        let borderColor = '#6b7280';

        if (isSimulator && impersonateId) {
            message = `SIMULATOR + USER: ${impersonateId}`;
            backgroundColor = '#dc2626'; // Red for simulator (higher priority)
            borderColor = '#dc2626';
        } else if (isSimulator) {
            message = 'SIMULATOR';
            backgroundColor = '#dc2626'; // Red
            borderColor = '#dc2626';
        } else if (impersonateId) {
            message = `USER: ${impersonateId}`;
            backgroundColor = '#f59e0b'; // Orange
            borderColor = '#f59e0b';
        }

        // Use header badge instead of fixed position indicator
        const badge = document.getElementById('mode-indicator-badge');

        if (message && badge) {
            // Display badge in header (small pill style)
            badge.innerHTML = message;
            badge.style.backgroundColor = backgroundColor;
            badge.style.color = '#ffffff';
            badge.style.fontSize = '10px';
            badge.style.fontWeight = '600';
            badge.style.padding = '2px 8px';
            badge.style.borderRadius = '10px';
            badge.style.fontFamily = 'monospace';
            badge.style.display = 'inline-block';
            badge.style.lineHeight = '1.2';

            console.log(`[VisualIndicators] Unified indicator displayed: ${message}`);
        } else if (badge) {
            // Clear badge if no message
            badge.innerHTML = '';
            badge.style.display = 'none';

            console.log('[VisualIndicators] All visual indicators cleared');
        }
    }
    
    function removeOldIndicators() {
        // Remove old separate indicators if they exist
        const simulatorIndicator = document.getElementById('simulator-mode-indicator');
        const impersonationIndicator = document.getElementById('impersonation-indicator');
        const unifiedIndicator = document.getElementById('unified-mode-indicator');
        
        if (simulatorIndicator) simulatorIndicator.remove();
        if (impersonationIndicator) impersonationIndicator.remove();
        if (unifiedIndicator) unifiedIndicator.remove();
        
        // Clear all header borders
        const header = document.getElementById('header');
        if (header) {
            header.style.borderTop = '';
            header.style.borderBottom = '';
            header.style.borderLeft = '';
        }
        
        console.log('[VisualIndicators] All visual indicators cleared');
    }
    
    // Expose functions to global scope
    window.updateUnifiedIndicator = updateUnifiedIndicator;
    window.reloadPatientLists = reloadPatientLists;
    window.setStorageValue = setStorageValue;
    window.getStorageValue = getStorageValue;
    
})(window);