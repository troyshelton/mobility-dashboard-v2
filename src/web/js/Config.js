// Global Configuration for Patient List MPage Template
// Pure configuration objects - admin functions moved to AdminCommands.js
(function(window) {
    'use strict';
    
    /**
     * SIMULATOR_CONFIG - Controls data source for all services with localStorage persistence
     * - enabled: true  = Use mock data (development/testing)
     * - enabled: false = Use real CCL programs (Cerner production)
     */
    const simulatorDefault = true; // Simulator mode enabled for local testing

    // Simulator mode ENABLED for local testing
    // For CERT/Production: Set to false via admin commands
    window.SIMULATOR_CONFIG = {
        enabled: true  // ENABLED - use mock data for local testing
    };

    console.log(`[Config] SIMULATOR_CONFIG initialized with enabled=${window.SIMULATOR_CONFIG.enabled} (simulator mode - using mock data)`);
    
    /**
     * USER_CONTEXT_CONFIG - Controls user impersonation for production support with localStorage persistence
     * - impersonatePersonId: null   = Use current user
     * - impersonatePersonId: number = Impersonate specific user (support scenarios)
     */
    const impersonateDefault = null; // Current user default
    const impersonateStored = window.getStorageValue ? 
        window.getStorageValue('patientListMPage_impersonatePersonId', impersonateDefault) :
        impersonateDefault;
    
    window.USER_CONTEXT_CONFIG = {
        impersonatePersonId: impersonateStored
    };
    
    console.log(`[Config] USER_CONTEXT_CONFIG initialized with impersonatePersonId=${window.USER_CONTEXT_CONFIG.impersonatePersonId} (stored=${impersonateStored}, default=${impersonateDefault})`);

    /**
     * AUTO_REFRESH_CONFIG - Controls automatic dashboard refresh (Issue #35)
     * - enabled: false = Auto-refresh disabled (default)
     * - enabled: true  = Auto-refresh enabled with periodic updates
     * - intervalMinutes: number = Minutes between refreshes (default 3)
     */
    const autoRefreshEnabledDefault = false; // Auto-refresh disabled by default
    const autoRefreshIntervalDefault = 3; // 3 minutes default interval

    const autoRefreshEnabled = window.getStorageValue ?
        window.getStorageValue('patientListMPage_autoRefreshEnabled', autoRefreshEnabledDefault) :
        autoRefreshEnabledDefault;

    const autoRefreshInterval = window.getStorageValue ?
        window.getStorageValue('patientListMPage_autoRefreshInterval', autoRefreshIntervalDefault) :
        autoRefreshIntervalDefault;

    window.AUTO_REFRESH_CONFIG = {
        enabled: autoRefreshEnabled,
        intervalMinutes: autoRefreshInterval
    };

    console.log(`[Config] AUTO_REFRESH_CONFIG initialized with enabled=${window.AUTO_REFRESH_CONFIG.enabled}, intervalMinutes=${window.AUTO_REFRESH_CONFIG.intervalMinutes}`);

    /**
     * Initialize unified indicator based on current configuration
     */
    console.log('[Config] Initializing unified visual indicator...');
    if (window.updateUnifiedIndicator) {
        window.updateUnifiedIndicator();
    } else {
        // Defer until VisualIndicators.js loads
        document.addEventListener('DOMContentLoaded', function() {
            if (window.updateUnifiedIndicator) {
                window.updateUnifiedIndicator();
            }
        });
    }
    
})(window);