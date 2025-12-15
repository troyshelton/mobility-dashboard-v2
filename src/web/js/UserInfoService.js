// User Info Service - Handles user authentication and environment info
(function(window) {
    'use strict';
    
    /**
     * UserInfoService - Manages user environment and authentication
     * Uses global SIMULATOR_CONFIG to determine simulator vs production mode
     * @param {boolean} debugMode - Whether to enable debug logging
     */
    function UserInfoService(debugMode = true) {
        this.debugMode = debugMode;
        this.userInfo = null;
        this.debugMessages = [];
        
        if (this.debugMode) {
            const isSimulator = window.SIMULATOR_CONFIG?.enabled;
            this._logDebug(`UserInfoService initialized in ${isSimulator ? 'simulator' : 'production'} mode (SIMULATOR_CONFIG.enabled = ${isSimulator})`);
        }
    }
    
    /**
     * Log debug messages using Eruda console
     */
    UserInfoService.prototype._logDebug = function(message, type = 'log') {
        if (this.debugMode) {
            console[type](`[UserInfoService] ${message}`);
        }
    };
    
    /**
     * Get user environment information
     * @returns {Promise<Object>} - User info object
     */
    UserInfoService.prototype.getUserEnvironmentInfo = async function() {
        if (this.userInfo) {
            return this.userInfo;
        }
        
        this._logDebug('Getting user environment info');
        
        try {
            let userInfo;
            
            // Check global configuration instead of service parameter
            const isSimulator = window.SIMULATOR_CONFIG?.enabled;
            
            if (isSimulator) {
                this._logDebug('Using simulator mode for user info (SIMULATOR_CONFIG.enabled = true)');
                userInfo = await this.loadMockUserInfo();
            } else {
                this._logDebug('Using production mode for user info (SIMULATOR_CONFIG.enabled = false)');
                
                if (typeof window.sendCclRequest === 'function') {
                    // Match respiratory MPage parameter pattern exactly
                    // Use empty string to let CCL program use reqinfo->updt_id (current user)
                    const response = await window.sendCclRequest(
                        '1_cust_mp_gen_user_info',
                        ['MINE', '', 0],  // Empty string = current user via reqinfo->updt_id
                        {
                            debug: this.debugMode,
                            timeout: 10000
                        }
                    );
                    
                    userInfo = response.REC || response;
                } else {
                    throw new Error('SendCclRequest not available in Millennium mode');
                }
            }
            
            this.userInfo = userInfo;
            this._logDebug('User info loaded successfully');
            
            return userInfo;
            
        } catch (error) {
            this._logDebug(`Error getting user info: ${error.message}`, 'error');
            throw error; // Always throw errors for proper troubleshooting
        }
    };
    
    /**
     * Load mock user information for simulator mode
     */
    UserInfoService.prototype.loadMockUserInfo = async function() {
        // Simulate network delay
        await new Promise(resolve => setTimeout(resolve, 100));
        
        return {
            personId: 8333417,
            userName: "TESTUSER",
            displayName: "Test User, Developer",
            position: "Developer",
            facility: "TEST FACILITY",
            domain: "BUILD",
            roles: ["Developer", "Administrator"],
            permissions: ["DEBUG_ACCESS", "PATIENT_LIST_ACCESS"]
        };
    };
    
    /**
     * Check if user has debug access
     * @returns {Promise<boolean>} - True if user has debug access
     */
    UserInfoService.prototype.hasDebugAccess = async function() {
        try {
            const userInfo = await this.getUserEnvironmentInfo();
            
            // Allow debug access for developers and specific positions
            const allowedPositions = [
                "Developer",
                "Administrator", 
                "P1 DBA",
                "P1 Acute Respiratory Therapist",
                "P1 Acute Outreach Services/Respiratory"
            ];
            
            const hasAccess = allowedPositions.includes(userInfo.position) ||
                             (userInfo.permissions && userInfo.permissions.includes('DEBUG_ACCESS'));
            
            this._logDebug(`Debug access check: ${hasAccess} (position: ${userInfo.position})`);
            
            return hasAccess;
            
        } catch (error) {
            this._logDebug(`Error checking debug access: ${error.message}`, 'error');
            // Default to false if we can't determine access
            return false;
        }
    };
    
    /**
     * Get current user ID
     * @returns {Promise<number>} - User person ID
     */
    UserInfoService.prototype.getUserId = async function() {
        try {
            const userInfo = await this.getUserEnvironmentInfo();
            return userInfo.personId;
        } catch (error) {
            this._logDebug(`Error getting user ID: ${error.message}`, 'error');
            // Return default for simulator mode
            return this.simulatorMode ? 8333417 : null;
        }
    };
    
    /**
     * Clear cached user info
     */
    UserInfoService.prototype.clearCache = function() {
        this.userInfo = null;
        this._logDebug('User info cache cleared');
    };
    
    // Expose to global scope
    window.UserInfoService = UserInfoService;
    
})(window);