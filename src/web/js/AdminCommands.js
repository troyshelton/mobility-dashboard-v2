// Admin Commands for Patient List MPage Template
// DBA-only functions for configuration and user impersonation
(function(window) {
    'use strict';
    
    /**
     * Security: Check if current user has DBA permissions for admin commands
     */
    async function checkDBAPermissions() {
        try {
            // Get current user info - handle both simulator and production modes
            let userInfo = null;
            
            if (window.PatientListApp && window.PatientListApp.services && window.PatientListApp.services.userInfo) {
                // Try to get user info - may fail if not in Cerner environment
                try {
                    userInfo = await window.PatientListApp.services.userInfo.getUserEnvironmentInfo();
                } catch (userInfoError) {
                    console.log(`[AdminCommands] UserInfoService failed, using simulator for permission check: ${userInfoError.message}`);
                    
                    // Fallback to simulator user info for permission checking
                    if (window.XMLCclRequestSimulator) {
                        const simulator = new window.XMLCclRequestSimulator();
                        const mockResponse = simulator.getMockUserInfo();
                        userInfo = mockResponse;
                        const userData = mockResponse.REC || mockResponse;
                        console.log(`[AdminCommands] Using mock user for permission check: ${userData.USER_NAME || userData.user_name}`);
                    }
                }
            }
            
            if (userInfo && userInfo.REC !== null) {
                // Handle both REC format (from CCL) and direct format
                const userData = userInfo.REC || userInfo;
                
                // SECURITY: Ensure we have valid user data
                if (!userData) {
                    console.error('🚫 [AdminCommands] SECURITY: No valid user data found - access denied');
                    return { authorized: false, userInfo: null };
                }
                
                const userName = userData.USER_NAME || userData.user_name || userData.displayName || 'Unknown User';
                const userPosition = userData.USER_POSITION || userData.user_position || userData.position || 'Unknown';
                const userId = userData.USER_ID || userData.user_id || userData.personId || 'Unknown';
                
                console.log(`[AdminCommands] Checking permissions for user: ${userName} (${userPosition})`);
                
                // Check for DBA positions using pattern matching - covers all DBA variants
                const hasValidPosition = userPosition && typeof userPosition === 'string';
                
                let matchesDBAPattern = false;
                if (hasValidPosition) {
                    const positionLower = userPosition.toLowerCase();
                    
                    // Pattern matching for DBA positions - ONLY positions ending with "DBA" or "DBA Lite"
                    matchesDBAPattern = 
                        positionLower.endsWith('dba') ||           // Covers: DBA, CPOE DBA, P1 DBA, etc.
                        positionLower.endsWith('dba lite');        // Covers: DBA Lite, CPOE DBA Lite, etc.
                        
                    console.log(`[AdminCommands] DBA pattern check: "${userPosition}"`);
                    console.log(`  - Ends with 'dba': ${positionLower.endsWith('dba')}`);
                    console.log(`  - Ends with 'dba lite': ${positionLower.endsWith('dba lite')}`);
                    console.log(`  - Pattern match result: ${matchesDBAPattern} (ONLY *DBA or *DBA Lite authorized)`);
                }
                
                console.log(`[AdminCommands] Security check details:`);
                console.log(`  - userId: ${userId}`);
                console.log(`  - userName: ${userName}`);
                console.log(`  - userPosition: ${userPosition}`);
                console.log(`  - hasValidPosition: ${hasValidPosition}`);
                console.log(`  - matchesDBAPattern: ${matchesDBAPattern}`);
                
                if (matchesDBAPattern && hasValidPosition) {
                    console.log(`✅ [AdminCommands] DBA permissions confirmed for ${userName} (${userPosition})`);
                    console.log(`✅ [AdminCommands] Authorization basis: DBA pattern match`);
                    return { authorized: true, userInfo: userInfo };
                } else {
                    console.warn(`🚫 [AdminCommands] SECURITY: Access denied for ${userName}`);
                    console.warn(`🚫 [AdminCommands] Position: ${userPosition}`);
                    console.warn(`🚫 [AdminCommands] Reason: ${!hasValidPosition ? 'Invalid position data' : 'Position does not contain DBA pattern'}`);
                    return { authorized: false, userInfo: userInfo };
                }
            } else {
                console.error('🚫 [AdminCommands] SECURITY: Cannot verify user identity - access denied');
                console.error('🚫 [AdminCommands] Reason: No user information available from any source');
                return { authorized: false, userInfo: null };
            }
        } catch (error) {
            console.error('🚫 [AdminCommands] SECURITY: Permission check failed - access denied');
            console.error('🚫 [AdminCommands] Error details:', error.message);
            return { authorized: false, userInfo: null };
        }
    }

    /**
     * Environment switching functions with localStorage persistence and security
     */
    window.enableSimulator = async function() {
        console.log('[AdminCommands] enableSimulator() called - checking permissions...');
        
        // Check DBA permissions first
        const permissionCheck = await checkDBAPermissions();
        if (!permissionCheck.authorized) {
            const errorMsg = `Access denied: Only DBA positions can enable simulator mode. Current user: ${permissionCheck.userInfo?.REC?.USER_NAME || permissionCheck.userInfo?.USER_NAME || 'Unknown'} (${permissionCheck.userInfo?.REC?.USER_POSITION || permissionCheck.userInfo?.USER_POSITION || 'Unknown'})`;
            console.error('🚫 ' + errorMsg);
            return errorMsg;
        }
        
        console.log('✅ Permission granted - enabling simulator mode...');
        
        // Update current configuration
        window.SIMULATOR_CONFIG.enabled = true;
        
        // SAFETY: Do NOT persist simulator mode - always resets to production on refresh
        console.log('🧪 Simulator mode enabled - using mock data for all services');
        console.log('🛡️ SAFETY: Simulator mode is session-only and will reset to production on page refresh');
        console.warn('⚠️ SIMULATOR MODE ACTIVE - USING MOCK DATA (resets on refresh)');
        
        // Update unified visual indicator
        if (window.updateUnifiedIndicator) {
            window.updateUnifiedIndicator();
        }
        
        // Automatically reload patient lists to populate dropdown immediately
        console.log('🔄 Reloading patient lists with new configuration...');
        if (window.reloadPatientLists) {
            window.reloadPatientLists();
        }
        
        return 'Simulator mode enabled (SESSION ONLY - will reset to production on refresh for safety). Patient lists reloaded.';
    };
    
    window.disableSimulator = async function() {
        console.log('[AdminCommands] disableSimulator() called - checking permissions...');
        
        // Check DBA permissions first
        const permissionCheck = await checkDBAPermissions();
        if (!permissionCheck.authorized) {
            const errorMsg = `Access denied: Only DBA positions can disable simulator mode. Current user: ${permissionCheck.userInfo?.REC?.USER_NAME || permissionCheck.userInfo?.USER_NAME || 'Unknown'} (${permissionCheck.userInfo?.REC?.USER_POSITION || permissionCheck.userInfo?.USER_POSITION || 'Unknown'})`;
            console.error('🚫 ' + errorMsg);
            return errorMsg;
        }
        
        console.log('✅ Permission granted - disabling simulator mode...');
        
        // Update current configuration
        window.SIMULATOR_CONFIG.enabled = false;
        
        // Persist production mode to localStorage (safe to persist)
        if (window.setStorageValue) {
            const stored = window.setStorageValue('patientListMPage_simulatorEnabled', false);
            
            if (stored) {
                console.log('🏥 Production mode enabled - using real CCL programs');
                console.log('💾 Production mode persisted to localStorage - will survive page refreshes');
            } else {
                console.log('🏥 Production mode enabled - using real CCL programs');
                console.warn('⚠️ Could not persist to localStorage - setting will reset on page refresh');
            }
        }
        
        // Update unified visual indicator
        if (window.updateUnifiedIndicator) {
            window.updateUnifiedIndicator();
        }
        
        // Automatically reload patient lists with new configuration
        console.log('🔄 Reloading patient lists with new configuration...');
        if (window.reloadPatientLists) {
            window.reloadPatientLists();
        }
        
        return 'Production mode enabled and persisted. Setting effective immediately. Patient lists reloaded.';
    };
    
    /**
     * User impersonation functions for production support
     */
    window.impersonateUser = async function(personId) {
        console.log(`[AdminCommands] impersonateUser(${personId}) called - checking permissions...`);
        
        // Check DBA permissions first
        const permissionCheck = await checkDBAPermissions();
        if (!permissionCheck.authorized) {
            const errorMsg = `Access denied: Only DBA positions can impersonate users. Current user: ${permissionCheck.userInfo?.REC?.USER_NAME || permissionCheck.userInfo?.USER_NAME || 'Unknown'} (${permissionCheck.userInfo?.REC?.USER_POSITION || permissionCheck.userInfo?.USER_POSITION || 'Unknown'})`;
            console.error('🚫 ' + errorMsg);
            return errorMsg;
        }
        
        console.log('✅ Permission granted - enabling user impersonation...');
        
        // Update current configuration  
        window.USER_CONTEXT_CONFIG.impersonatePersonId = personId;
        
        // Persist to localStorage
        if (window.setStorageValue) {
            const stored = window.setStorageValue('patientListMPage_impersonatePersonId', personId);
            
            if (stored) {
                console.log('🔧 Impersonating person_id: ' + personId + ' (using real CCL programs with this user context)');
                console.log('💾 Impersonation persisted to localStorage - will survive page refreshes');
            } else {
                console.log('🔧 Impersonating person_id: ' + personId + ' (using real CCL programs with this user context)');
                console.warn('⚠️ Could not persist impersonation to localStorage - will reset on refresh');
            }
        }
        
        // Update unified visual indicator
        if (window.updateUnifiedIndicator) {
            window.updateUnifiedIndicator();
        }
        
        return 'Now impersonating person_id: ' + personId + '. Setting effective immediately and persisted.';
    };
    
    window.clearImpersonation = function() {
        console.log('[AdminCommands] clearImpersonation() called');
        
        // Clear current configuration
        window.USER_CONTEXT_CONFIG.impersonatePersonId = null;
        
        // Update unified visual indicator
        if (window.updateUnifiedIndicator) {
            window.updateUnifiedIndicator();
        }
        
        // Remove from localStorage  
        try {
            localStorage.removeItem('patientListMPage_impersonatePersonId');
            console.log('[AdminCommands] localStorage.removeItem(impersonatePersonId) - SUCCESS');
            console.log('👤 Cleared impersonation - using current user context');
            console.log('💾 Impersonation cleared from localStorage');
            return 'Using current user context. Setting effective immediately and persisted.';
        } catch (error) {
            console.error('[AdminCommands] localStorage.removeItem() FAILED:', error.message);
            console.log('👤 Cleared impersonation - using current user context');
            return 'Using current user context (current session only).';
        }
    };
    
    /**
     * Debug control functions (admin-level)
     */
    window.enableDebug = function() {
        if (window.DEBUG_CONFIG) {
            window.DEBUG_CONFIG.enabled = true;
        }
        console.log('🐛 Debug Mode Enabled');
        return 'Debug mode enabled.';
    };
    
    window.disableDebug = function() {
        if (window.DEBUG_CONFIG) {
            window.DEBUG_CONFIG.enabled = false;
        }
        console.log('Debug mode disabled');
        return 'Debug mode disabled.';
    };
    
    /**
     * Configuration inspection functions
     */
    window.showConfig = function() {
        console.log('📋 Current Configuration:');
        console.log('SIMULATOR_CONFIG:', window.SIMULATOR_CONFIG);
        console.log('USER_CONTEXT_CONFIG:', window.USER_CONTEXT_CONFIG);
        if (window.DEBUG_CONFIG) {
            console.log('DEBUG_CONFIG:', window.DEBUG_CONFIG);
        }
        return {
            simulator: window.SIMULATOR_CONFIG,
            userContext: window.USER_CONTEXT_CONFIG,
            debug: window.DEBUG_CONFIG
        };
    };
    
})(window);