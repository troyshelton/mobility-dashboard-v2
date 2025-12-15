# Healthcare Order Status Icons - Implementation Guide

## Overview
Professional medical progress indicators for healthcare order status using CSS-based circular icons with visual progression patterns. Specifically designed for healthcare environments and clinical workflows.

## Visual Design Pattern
The healthcare order status icons use a **visual progression system**:
1. **Empty Circle** (Not Started) - Order not yet initiated
2. **Half-Filled Circle** (Pending) - Order in progress/pending  
3. **Filled Circle with Checkmark** (Completed) - Order completed/active

## Icon Specifications

### 1. Not Started (Empty Circle)
**Visual:** Empty circle with gray border  
**Meaning:** PowerPlan not ordered  
**CSS Class:** `progress-not-started`

```css
.progress-not-started {
  width: 20px;
  height: 20px;
  border: 2px solid #6c757d;
  border-radius: 50%;
  background-color: transparent;
  box-sizing: border-box;
  margin: 0 auto;
}
```

### 2. Pending (Half-Filled Circle)
**Visual:** Circle filled 50% from left with yellow gradient  
**Meaning:** PowerPlan ordered but not yet initiated  
**CSS Class:** `progress-pending`

```css
.progress-pending {
  width: 20px;
  height: 20px;
  background: linear-gradient(90deg, #ffc107 50%, #f8f9fa 50%);
  border: 2px solid #ffc107;
  border-radius: 50%;
  box-sizing: border-box;
  margin: 0 auto;
}
```

### 3. Completed (Filled Circle with Checkmark)
**Visual:** Green filled circle with white checkmark  
**Meaning:** PowerPlan initiated and active  
**CSS Class:** `progress-completed`

```css
.progress-completed {
  width: 20px;
  height: 20px;
  background-color: #28a745;
  border: 2px solid transparent;
  border-radius: 50%;
  color: white;
  box-sizing: border-box;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: bold;
  margin: 0 auto;
}
```

## Clinical Status Mapping by Intervention Type

### PowerPlan Status Mapping (Execution-Focused)
**Clinical Context**: Focuses on whether sepsis protocol was executed, regardless of current status.

| PowerPlan Status | CSS Class | Visual | Clinical Meaning |
|------------------|-----------|---------|------------------|
| **"Y"** | `progress-completed` | 🟢 Green circle with ✓ | PowerPlan initiated OR discontinued (executed) |
| **"Pend"** | `progress-pending` | 🟡 Half-filled yellow circle | PowerPlan planned but not started |
| **"N"** | `progress-not-started` | ⚪ Empty gray circle | PowerPlan cancelled or not ordered |

### Blood Culture Status Mapping (Collection-Focused)
**Clinical Context**: Focuses on physical blood collection for antibiotic administration safety.

| Blood Culture Status | CSS Class | Visual | Clinical Meaning |
|---------------------|-----------|---------|------------------|
| **"Y"** | `progress-completed` | 🟢 Green circle with ✓ | At least one blood culture collected - SAFE for antibiotics |
| **"Pend"** | `progress-pending` | 🟡 Half-filled yellow circle | Blood cultures ordered but none collected - HOLD antibiotics |
| **"N"** | `progress-not-started` | ⚪ Empty gray circle | Blood cultures cancelled or not ordered |

### Lactate Status Mapping (Processing-Focused)  
**Clinical Context**: Focuses on lab processing status for clinical decision making.

| Lactate Status | CSS Class | Visual | Clinical Meaning |
|----------------|-----------|---------|------------------|
| **"Y"** | `progress-completed` | 🟢 Green circle with ✓ | Lactate dispatched to lab or resulted |
| **"Pend"** | `progress-pending` | 🟡 Half-filled yellow circle | Lactate ordered but not sent to lab |
| **"N"** | `progress-not-started` | ⚪ Empty gray circle | Lactate cancelled or not ordered |

## Implementation in Handsontable

### PowerPlan Renderer Function
```javascript
function powerplanRenderer(instance, td, row, col, prop, value, cellProperties) {
    let htmlContent = '';
    
    switch (value) {
        case 'Y':
            htmlContent = '<div class="progress-completed" aria-label="PowerPlan initiated">✓</div>';
            break;
        case 'Pend':
            htmlContent = '<div class="progress-pending" aria-label="PowerPlan pending"></div>';
            break;
        case 'N':
            htmlContent = '<div class="progress-not-started" aria-label="PowerPlan not ordered"></div>';
            break;
        default:
            htmlContent = '<div style="text-align: center; color: #9ca3af;">--</div>';
    }
    
    td.innerHTML = htmlContent;
    td.style.textAlign = 'center';
    td.style.verticalAlign = 'middle';
    return td;
}
```

## Healthcare Benefits

### Clinical Advantages
- **Visual progression** - Shows natural workflow advancement (empty → half → full)
- **Professional medical appearance** - Designed specifically for healthcare contexts
- **No confusion with medical alerts** - Gray (not red) for "not started"
- **Intuitive understanding** - Progress indicators universally recognized

### Technical Advantages
- **CSS-based** - No external icon library dependencies
- **Consistent sizing** - All icons exactly 20px × 20px
- **Accessibility built-in** - Includes aria-labels for screen readers
- **Scalable** - Pure CSS, works at any table size
- **Healthcare color standards** - Colors avoid confusion with medical alert systems

## Accessibility Features
- **WCAG AA compliant** colors with sufficient contrast
- **Aria-labels** for screen reader accessibility
- **Shape differentiation** - Different visual patterns for colorblind users
- **Consistent dimensions** - Predictable layout for assistive technologies

## Future Application
This healthcare order status system can be applied to all sepsis intervention columns:
- **Lactate Ordered**: Empty → Half → Full with ✓
- **Blood Cultures Ordered**: Empty → Half → Full with ✓
- **Antibiotics Ordered**: Empty → Half → Full with ✓
- **Sepsis Fluids Ordered**: Empty → Half → Full with ✓

## Color Specifications
| State | Background | Border | Symbol |
|-------|------------|--------|---------|
| Not Started | `transparent` | `#6c757d` (Gray) | None |
| Pending | `#ffc107` (Yellow) + `#f8f9fa` (Light gray) | `#ffc107` (Yellow) | None |
| Completed | `#28a745` (Green) | `transparent` | `white` checkmark |

## Browser Compatibility
- **CSS Gradients**: Supported in all modern browsers (IE10+)
- **Flexbox**: Supported for checkmark centering (IE11+)
- **Border-radius**: Widely supported across all browsers

---
*Healthcare Order Status Icons Implementation Guide*  
*Based on Technical Specification v3*  
*Implemented: 2025-09-09*  
*Sepsis Dashboard v1.2.0*