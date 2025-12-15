/**
 * CCL Request Handler for Patient List MPage Template
 * Based on proven respiratory MPage SendCclRequest.js
 * Provides functionality to send CCL requests to Millennium or use a simulator
 * with enhanced debug logging and execution timing
 */
(function(window) {
    // Execution time thresholds in milliseconds
    const EXECUTION_THRESHOLDS = {
        FAST: 60000,    // Under 1 minute is fast
        MEDIUM: 180000  // Under 3 minutes is medium, over is slow
    };

    /**
     * Format execution time with appropriate color coding
     * @param {number} executionTime - Time in milliseconds
     * @returns {string} - Formatted time string with color indicator
     */
    function formatExecutionTime(executionTime) {
        let color;
        let formattedTime;
        
        // Determine color based on thresholds
        if (executionTime < EXECUTION_THRESHOLDS.FAST) {
            color = '#4CAF50'; // Green for fast
        } else if (executionTime < EXECUTION_THRESHOLDS.MEDIUM) {
            color = '#FFC107'; // Yellow for medium
        } else {
            color = '#F44336'; // Red for slow
        }
        
        // Format time based on duration
        if (executionTime < 1000) {
            // Less than 1 second - display milliseconds
            formattedTime = `${Math.round(executionTime)}ms`;
        } else if (executionTime < 60000) {
            // Less than 1 minute - display seconds with 1 decimal
            const seconds = (executionTime / 1000).toFixed(1);
            formattedTime = `${seconds}s`;
        } else {
            // 1 minute or more - display minutes and seconds
            const minutes = Math.floor(executionTime / 60000);
            const seconds = Math.floor((executionTime % 60000) / 1000);
            formattedTime = `${minutes}m ${seconds}s`;
        }
        
        return `<span style="color: ${color}">${formattedTime}</span>`;
    }

    /**
     * Format JSON response for debug output
     * @param {string} responseText - Raw response text
     * @returns {string} - Formatted response summary
     */
    function formatResponseSummary(responseText) {
        try {
            const data = JSON.parse(responseText);
            const isArray = Array.isArray(data);
            const count = isArray ? data.length : 1;
            const type = isArray ? 'array' : typeof data;
            return `[${type}:${count} items] ${JSON.stringify(data).substring(0, 100)}...`;
        } catch (e) {
            return responseText.substring(0, 100) + '...';
        }
    }
    
    /**
     * Formats CCL parameters to ensure proper quoting and escaping
     * @param {*} param - The parameter to format
     * @param {boolean} rawFormat - Whether to skip adding quotes
     * @returns {string} - Formatted parameter
     */
    function formatCclParameter(param, rawFormat = false) {
        // If rawFormat is true, return the parameter as-is without adding quotes
        if (rawFormat === true) {
            return String(param);
        }
        
        // If param is null or undefined, return empty string
        if (param === null || param === undefined) {
            return '""';
        }

        // If already a string, add quotes if not already present
        if (typeof param === 'string') {
            // Skip adding quotes if this is a value() function
            if (param.startsWith('value(') && param.endsWith(')')) {
                return param;
            }
            
            // Remove existing quotes if present
            param = param.replace(/^["']|["']$/g, '');
            
            // Escape any internal quotes
            param = param.replace(/"/g, '\\"');
            
            // Add quotes
            return `"${param}"`;
        }

        // For numbers, booleans, etc., convert to string and quote
        return `"${String(param)}"`;
    }

    /**
     * Sends a CCL request to the Millennium server or use simulator based on SIMULATOR_CONFIG
     * @param {string} cclObj - The CCL object name
     * @param {Array} params - Parameters to pass to the CCL object
     * @param {Object} options - Additional options (debug: boolean, timeout: number)
     * @returns {Promise} - Promise that resolves with the response text
     */
    function sendCclRequest(cclObj, params = [], options = {}) {
        return new Promise((resolve, reject) => {
            // Parse options
            const debug = options.debug || false;
            const timeout = options.timeout || 90000; // Tripled to 90-second timeout for BLOB data processing
            
            // Check SIMULATOR_CONFIG for mode determination
            const useSimulator = window.SIMULATOR_CONFIG?.enabled;
            
            // Detect if running in Millennium environment
            const inMillennium = "XMLCclRequest" in window.external;
            
            // Start timing
            const startTime = performance.now();
            
            // Enhanced logging
            if (debug) {
                console.log(`[SendCclRequest] Calling ${cclObj} with parameters:`, params);
                console.log(`[SendCclRequest] Configuration: SIMULATOR_CONFIG.enabled=${useSimulator}, XMLCclRequest available=${inMillennium}`);
                console.log(`[SendCclRequest] Environment: ${inMillennium ? 'Millennium' : 'Local'}, UseSimulator: ${useSimulator}`);
            }
            
            // Create appropriate request object
            let xcr;
            try {
                if (useSimulator) {
                    if (debug) {
                        console.log(`[SendCclRequest] Using simulator mode for ${cclObj} (SIMULATOR_CONFIG.enabled = true)`);
                    }
                    
                    // Use simulator
                    if (typeof window.XMLCclRequestSimulator === 'function') {
                        const simulator = new window.XMLCclRequestSimulator();
                        simulator.simulateRequest(cclObj, params)
                            .then(resolve)
                            .catch(reject);
                        return;
                    } else {
                        reject(new Error(`XMLCclRequestSimulator not available. Cannot simulate ${cclObj}.`));
                        return;
                    }
                } else {
                    if (!inMillennium) {
                        throw new Error(`CCL not available and SIMULATOR_CONFIG.enabled = false. Cannot call ${cclObj}.`);
                    }
                    
                    try {
                        // Note: don't use 'new' with XMLCclRequest in Millennium (from respiratory)
                        xcr = window.external.XMLCclRequest();
                    } catch (error) {
                        if (debug) {
                            console.error("Failed to create XMLCclRequest: " + error.message);
                        }
                        throw error;
                    }
                }
            } catch (error) {
                return reject(new Error(`Failed to create request object: ${error.message}`));
            }

            // Set up timeout mechanism
            const timeoutId = setTimeout(() => {
                if (xcr.readyState !== 4) {
                    xcr.abort(); // Cancel the request
                    const timeoutError = new Error(`Request to ${cclObj} timed out after ${timeout}ms`);
                    timeoutError.errorType = 'TIMEOUT';
                    reject(timeoutError);
                }
            }, timeout);

            // Set up request
            xcr.open("GET", cclObj);
            
            // Handle response
            xcr.onreadystatechange = () => {
                if (xcr.readyState === 4) {
                    // Clear the timeout
                    clearTimeout(timeoutId);

                    if (xcr.status === 200) {
                        // Calculate execution time
                        const executionTime = performance.now() - startTime;
                        
                        if (debug) {
                            // Log completion with execution time
                            console.log(`[SendCclRequest] Completed: ${cclObj} in ${formatExecutionTime(executionTime)}`);
                            
                            // Log response summary
                            console.log(`[SendCclRequest] Response summary: ${formatResponseSummary(xcr.responseText)}`);
                        }
                        
                        // Parse JSON response if needed
                        try {
                            const response = JSON.parse(xcr.responseText);
                            resolve(response);
                        } catch (parseError) {
                            if (debug) {
                                console.warn('[SendCclRequest] Response is not JSON format, returning as text');
                            }
                            resolve(xcr.responseText);
                        }
                    } else {
                        const errorMsg = `CCL request failed with status: ${xcr.status}`;
                        if (debug) {
                            console.error('[SendCclRequest] Request failed:', new Error(errorMsg));
                        }
                        reject(new Error(errorMsg));
                    }
                }
            };
            
            // Handle errors
            xcr.onerror = (error) => {
                // Clear the timeout
                clearTimeout(timeoutId);
                const errorMsg = `CCL request error: ${error || 'Unknown error'}`;
                if (debug) {
                    console.error('[SendCclRequest] Request error:', new Error(errorMsg));
                }
                reject(new Error(errorMsg));
            };
            
            // Format and send parameters (respiratory MPage approach)
            let formattedParams;
            
            // Check if the params array has special formatting properties
            if (params.raw === true) {
                // Use all parameters as-is without additional formatting
                formattedParams = params;
                
                if (debug) {
                    console.log(`[SendCclRequest] Using all parameters as raw without quotes`);
                }
            } else if (params.rawStart !== undefined) {
                // Mixed mode - format some parameters normally and others as raw
                const rawStartIndex = params.rawStart;
                
                // Process parameters before the rawStart index with formatCclParameter
                // and leave parameters from rawStart onwards as-is
                formattedParams = params.map((param, index) => {
                    if (index < rawStartIndex) {
                        return formatCclParameter(param);
                    } else {
                        return param;
                    }
                });
                
                if (debug) {
                    console.log(`[SendCclRequest] Using mixed parameter formatting (raw from index ${rawStartIndex})`);
                }
            } else {
                // Apply normal parameter formatting to all parameters
                formattedParams = params.map(formatCclParameter);
            }
            
            const paramStr = formattedParams.join(",");
            
            if (debug) {
                console.log(`[SendCclRequest] Formatted parameters: ${paramStr}`);
            }
            
            xcr.send(paramStr);
        });
    }

    // Expose to global scope
    window.sendCclRequest = sendCclRequest;
})(window);