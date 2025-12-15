# AI Chat UI Options - Testing Guide

## Current Issue
The AI chat panel (400px wide, right-side) blocks the patient table data. You can't see table columns while reviewing AI responses.

## Three UI Options to Test

### **Option 1: Split-Pane (Side-by-Side)**
**Implementation:** Table shrinks to 65% width, Chat takes 35% width, side-by-side

**How to test:**
1. Open browser console (F12)
2. Run this code:
```javascript
// Resize table to 65% width
document.getElementById('main').style.width = '65%';
document.getElementById('main').style.display = 'inline-block';
document.getElementById('main').style.verticalAlign = 'top';

// Make chat panel 35% width, always visible
const chat = document.getElementById('ai-chat-panel');
chat.style.width = '35%';
chat.style.position = 'fixed';
chat.style.top = '40px';
chat.style.right = '0';
chat.style.display = 'flex';
chat.classList.add('visible');
```

**Result:** Table and chat side-by-side. Table may need horizontal scrolling for all 16 columns.

---

### **Option 2: Floating Draggable Window**
**Implementation:** Small movable chat window (300x400px) that you can drag anywhere

**How to test:**
1. Open browser console (F12)
2. Run this code:
```javascript
const chat = document.getElementById('ai-chat-panel');
chat.style.width = '350px';
chat.style.height = '500px';
chat.style.position = 'fixed';
chat.style.top = '100px';
chat.style.right = '50px';
chat.style.borderRadius = '8px';
chat.style.boxShadow = '0 4px 20px rgba(0,0,0,0.3)';
chat.style.display = 'flex';
chat.classList.add('visible');

// Make header draggable
const header = chat.querySelector('div');
header.style.cursor = 'move';
let isDragging = false;
let currentX, currentY, initialX, initialY;

header.addEventListener('mousedown', (e) => {
  isDragging = true;
  initialX = e.clientX - chat.offsetLeft;
  initialY = e.clientY - chat.offsetTop;
});

document.addEventListener('mousemove', (e) => {
  if (isDragging) {
    e.preventDefault();
    currentX = e.clientX - initialX;
    currentY = e.clientY - initialY;
    chat.style.left = currentX + 'px';
    chat.style.top = currentY + 'px';
    chat.style.right = 'auto';
  }
});

document.addEventListener('mouseup', () => {
  isDragging = false;
});
```

**Result:** Draggable chat window you can move anywhere on screen.

---

### **Option 3: Bottom Drawer (Slides Up from Bottom)**
**Implementation:** Chat slides up from bottom, table stays above

**How to test:**
1. Open browser console (F12)
2. Run this code:
```javascript
const chat = document.getElementById('ai-chat-panel');
chat.style.width = '100%';
chat.style.height = '40%';
chat.style.position = 'fixed';
chat.style.top = 'auto';
chat.style.bottom = '0';
chat.style.left = '0';
chat.style.right = '0';
chat.style.borderTop = '3px solid #1e3a8a';
chat.style.borderLeft = 'none';
chat.style.display = 'flex';
chat.classList.add('visible');

// Shrink table height to make room
document.getElementById('main').style.height = 'calc(60vh - 40px)';
document.getElementById('main').style.overflow = 'auto';
```

**Result:** Chat at bottom, table at top. Both visible simultaneously.

---

## Quick Test Without Console

**Easiest way:** I can create 3 separate test pages you can open:
1. `test-split-pane.html`
2. `test-floating.html`
3. `test-bottom-drawer.html`

Each will have the UI pre-configured so you just open and test!

**Would you like me to create these 3 test pages?** (5 minutes to build all three)

## My Recommendation

For healthcare dashboards, **Option 2 (Floating Draggable)** is best because:
- ✅ Table stays full-width (see all patient columns)
- ✅ Move chat out of the way when needed
- ✅ Similar to Epic/Oracle Health patterns
- ✅ Flexible for different screen sizes

But test all three and decide what feels best for YOUR workflow!
