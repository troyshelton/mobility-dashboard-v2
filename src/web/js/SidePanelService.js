/**
 * SidePanelService
 * Manages side panel UI for displaying historical metric data (dynamic lookback period)
 *
 * Pattern: Clinical Leader Organizer (Cerner standard)
 * Issue: #3 - Side Panel Historical Metric View
 *
 * Responsibilities:
 * - Panel DOM creation and lifecycle
 * - Historical data rendering
 * - Open/close animations and interactions
 * - Accessibility (ESC key, focus management, ARIA labels)
 *
 * @example
 * // Open panel with historical data
 * sidePanelService.open(
 *   patientRecord,
 *   'morse',
 *   'Morse Fall Risk Score',
 *   historyData
 * );
 *
 * // Close panel
 * sidePanelService.close();
 */
class SidePanelService {
  constructor() {
    this.panel = null;
    this.backdrop = null;
    this.isOpen = false;
    this.currentMetric = null;
    this.currentPatient = null;

    this._initializePanel();
    this._bindEvents();
  }

  /**
   * Creates panel DOM structure and injects into document
   * @private
   */
  _initializePanel() {
    // Backdrop overlay
    this.backdrop = document.createElement('div');
    this.backdrop.className = 'panel-backdrop';
    this.backdrop.style.display = 'none';

    // Side panel container
    this.panel = document.createElement('div');
    this.panel.className = 'side-panel';
    this.panel.innerHTML = `
      <div class="panel-header">
        <h3 class="panel-title"></h3>
        <button class="panel-close" aria-label="Close panel" title="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="panel-body">
        <div class="panel-patient-info"></div>
        <div class="panel-content"></div>
      </div>
    `;

    document.body.appendChild(this.backdrop);
    document.body.appendChild(this.panel);

    console.log('✅ SidePanelService initialized');
  }

  /**
   * Binds event listeners for panel interactions
   * @private
   */
  _bindEvents() {
    // Close button
    this.panel.querySelector('.panel-close').addEventListener('click', () => {
      console.log('Panel close button clicked');
      this.close();
    });

    // Backdrop click
    this.backdrop.addEventListener('click', () => {
      console.log('Panel backdrop clicked');
      this.close();
    });

    // ESC key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.isOpen) {
        console.log('ESC key pressed, closing panel');
        this.close();
      }
    });
  }

  /**
   * Opens panel with historical data for a metric
   * @param {Object} patient - Patient record from table row
   * @param {string} metricKey - Metric identifier (e.g., 'morse', 'call_light')
   * @param {string} metricLabel - Human-readable metric name
   * @param {Array<Object>} historyData - Historical entries [{datetime: Date, value: string}]
   * @param {number} lookbackDays - Number of days in lookback period (default 30)
   */
  open(patient, metricKey, metricLabel, historyData, lookbackDays = 30) {
    console.log('Opening side panel:', { patient, metricKey, metricLabel, historyData, lookbackDays });

    this.currentMetric = metricKey;
    this.currentPatient = patient;
    this.currentLookbackDays = lookbackDays;

    // Update panel title with dynamic lookback period
    this.panel.querySelector('.panel-title').textContent =
      `${metricLabel} - ${lookbackDays} Day History`;

    // Update patient info
    this._renderPatientInfo(patient);

    // Render history
    this._renderHistory(historyData);

    // Show panel with animation
    this.backdrop.style.display = 'block';
    requestAnimationFrame(() => {
      this.backdrop.classList.add('active');
      this.panel.classList.add('open');
    });

    this.isOpen = true;

    // Focus management (accessibility)
    setTimeout(() => {
      this.panel.querySelector('.panel-close').focus();
    }, 350); // After animation completes
  }

  /**
   * Renders patient information section
   * @private
   * @param {Object} patient - Patient record
   */
  _renderPatientInfo(patient) {
    const infoDiv = this.panel.querySelector('.panel-patient-info');

    infoDiv.innerHTML = `
      <div class="patient-info-grid">
        <div class="patient-info-row">
          <span class="patient-info-label">Patient:</span>
          <span class="patient-info-value">${patient.person_name || patient.name_full_formatted || 'Unknown'}</span>
        </div>
        <div class="patient-info-row">
          <span class="patient-info-label">MRN:</span>
          <span class="patient-info-value">${patient.mrn || 'N/A'}</span>
        </div>
        <div class="patient-info-row">
          <span class="patient-info-label">Location:</span>
          <span class="patient-info-value">${patient.unit || patient.location || 'N/A'} ${patient.roomBed ? '- ' + patient.roomBed : ''}</span>
        </div>
      </div>
    `;
  }

  /**
   * Renders historical data entries
   * @private
   * @param {Array<Object>} historyData - [{datetime: Date, value: string}]
   */
  _renderHistory(historyData) {
    const contentDiv = this.panel.querySelector('.panel-content');

    if (!historyData || historyData.length === 0) {
      const days = this.currentLookbackDays || 30;
      contentDiv.innerHTML = `
        <div class="empty-state">
          <i class="fas fa-inbox" style="font-size: 3rem; color: #ccc; margin-bottom: 1rem;"></i>
          <p>No data available for the past ${days} days</p>
        </div>
      `;
      return;
    }

    // Check if values are numeric for sparkline rendering
    const isNumeric = this._isNumericMetric(historyData);

    // Only show sparkline if numeric AND has at least 2 data points
    const showSparkline = isNumeric && historyData.length >= 2;

    // Generate sparkline if conditions met
    const sparklineHTML = showSparkline ? `
      <div class="sparkline-container">
        <canvas id="metric-sparkline" class="metric-sparkline"></canvas>
      </div>
    ` : '';

    const historyHTML = historyData.map(entry => `
      <div class="history-entry">
        <div class="history-datetime">
          <i class="far fa-clock"></i>
          ${this._formatDateTime(entry.datetime)}
        </div>
        <div class="history-value">
          ${entry.value}
        </div>
      </div>
    `).join('');

    contentDiv.innerHTML = `
      ${sparklineHTML}
      <div class="history-list">
        ${historyHTML}
      </div>
      <div class="history-footer">
        <i class="fas fa-info-circle"></i>
        ${historyData.length} ${historyData.length === 1 ? 'entry' : 'entries'} over ${this.currentLookbackDays || lookbackDays} days
      </div>
    `;

    // Render sparkline if conditions met
    if (showSparkline) {
      requestAnimationFrame(() => {
        this._renderSparkline(historyData);
      });
    }
  }

  /**
   * Checks if metric values are numeric
   * @private
   * @param {Array<Object>} historyData - Historical data array
   * @returns {boolean} True if values are numeric
   */
  _isNumericMetric(historyData) {
    if (!historyData || historyData.length === 0) return false;

    // Check first few entries to determine if numeric
    const sample = historyData.slice(0, 3);
    return sample.every(entry => {
      const value = String(entry.value).trim();
      // Check if it's a number (allowing decimals)
      return /^-?\d+\.?\d*$/.test(value) && !isNaN(parseFloat(value));
    });
  }

  /**
   * Renders a sparkline chart for numeric metrics (jQuery Sparklines style)
   * Simple inline line graph without axes or labels
   * @private
   * @param {Array<Object>} historyData - Historical data with numeric values
   */
  _renderSparkline(historyData) {
    const canvas = document.getElementById('metric-sparkline');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const dpr = window.devicePixelRatio || 1;

    // Set canvas size (compact inline style)
    const width = 360;
    const height = 50;
    canvas.width = width * dpr;
    canvas.height = height * dpr;
    canvas.style.width = width + 'px';
    canvas.style.height = height + 'px';
    ctx.scale(dpr, dpr);

    // Extract numeric values (reverse to show oldest → newest left to right)
    const values = [...historyData].reverse().map(entry => parseFloat(entry.value));

    // Calculate min/max for scaling
    const minValue = Math.min(...values);
    const maxValue = Math.max(...values);
    const range = maxValue - minValue || 1; // Prevent division by zero

    // Minimal padding for inline style
    const padding = 5;
    const chartWidth = width - (padding * 2);
    const chartHeight = height - (padding * 2);

    // Calculate point positions
    const points = values.map((value, index) => {
      const x = padding + (index / (values.length - 1)) * chartWidth;
      const y = padding + chartHeight - ((value - minValue) / range) * chartHeight;
      return { x, y, value };
    });

    // Clear background
    ctx.clearRect(0, 0, width, height);

    // Draw subtle area fill
    ctx.fillStyle = 'rgba(33, 150, 243, 0.15)';
    ctx.beginPath();
    ctx.moveTo(points[0].x, height - padding);
    points.forEach(point => ctx.lineTo(point.x, point.y));
    ctx.lineTo(points[points.length - 1].x, height - padding);
    ctx.closePath();
    ctx.fill();

    // Draw line
    ctx.strokeStyle = '#2196f3';
    ctx.lineWidth = 2;
    ctx.lineJoin = 'round';
    ctx.lineCap = 'round';
    ctx.beginPath();
    points.forEach((point, index) => {
      if (index === 0) {
        ctx.moveTo(point.x, point.y);
      } else {
        ctx.lineTo(point.x, point.y);
      }
    });
    ctx.stroke();

    // Draw small dots on data points
    points.forEach(point => {
      ctx.fillStyle = '#2196f3';
      ctx.beginPath();
      ctx.arc(point.x, point.y, 2.5, 0, Math.PI * 2);
      ctx.fill();
    });

    // Highlight last point (current value)
    const lastPoint = points[points.length - 1];
    ctx.fillStyle = '#ffffff';
    ctx.strokeStyle = '#2196f3';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(lastPoint.x, lastPoint.y, 4, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    console.log('✅ Sparkline rendered:', { values, minValue, maxValue });
  }

  /**
   * Formats Date object for display
   * @private
   * @param {Date} date - JavaScript Date object
   * @returns {string} Formatted date string "MM/DD/YYYY HH:MM AM/PM"
   */
  _formatDateTime(date) {
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const year = date.getFullYear();

    let hours = date.getHours();
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12 || 12;

    return `${month}/${day}/${year} ${hours}:${minutes} ${ampm}`;
  }

  /**
   * Closes panel with animation
   */
  close() {
    if (!this.isOpen) {
      console.log('Panel already closed');
      return;
    }

    console.log('Closing panel');

    this.backdrop.classList.remove('active');
    this.panel.classList.remove('open');

    // Wait for animation to complete
    setTimeout(() => {
      this.backdrop.style.display = 'none';
      this.isOpen = false;
      this.currentMetric = null;
      this.currentPatient = null;
    }, 300); // Match CSS transition duration
  }
}

// Export singleton instance
const sidePanelService = new SidePanelService();
window.sidePanelService = sidePanelService;
