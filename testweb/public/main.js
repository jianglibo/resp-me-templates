/* Scripts for css grid dashboard */

document.addEventListener('DOMContentLoaded', () => {
  addResizeListeners();
  setSidenavListeners();
  setUserDropdownListener();
  renderChart();
  setMenuClickListener();
  setSidenavCloseListener();
});

// Set constants and grab needed elements
const sidenavEl = document.querySelector('.sidenav');
const gridEl = document.querySelector('.grid');
const SIDENAV_ACTIVE_CLASS = 'sidenav--active';
const GRID_NO_SCROLL_CLASS = 'grid--noscroll';

function toggleClass(el, className) {
  if (el.classList.contains(className)) {
    el.classList.remove(className);
  } else {
    el.classList.add(className);
  }
}

// User avatar dropdown functionality
function setUserDropdownListener() {
  const userAvatar = document.querySelector('.header__avatar');

  userAvatar.addEventListener('click', function(e) {
    const dropdown = this.querySelector('.dropdown');
    toggleClass(dropdown, 'dropdown--active');
  });
}

// Sidenav list sliding functionality
function setSidenavListeners() {
  const subHeadings = document.querySelectorAll('.navList__subheading');
  const SUBHEADING_OPEN_CLASS = 'navList__subheading--open';
  const SUBLIST_HIDDEN_CLASS = 'subList--hidden';

  subHeadings.forEach((subHeadingEl) => {
    subHeadingEl.addEventListener('click', (e) => {
      const subListEl = subHeadingEl.nextElementSibling;

      // Add/remove selected styles to list category heading
      toggleClass(subHeadingEl, SUBHEADING_OPEN_CLASS);

      // Reveal/hide the sublist
      if (subListEl) {
        toggleClass(subListEl, SUBLIST_HIDDEN_CLASS);
      }
    });
  });
}

// Draw the chart
function renderChart() {
  // Your chart rendering code using AmCharts here
}

// If user opens the menu and then expands the viewport from mobile size without closing the menu,
// make sure scrolling is enabled again and that sidenav active class is removed
function addResizeListeners() {
  window.addEventListener('resize', (e) => {
    const width = window.innerWidth;

    if (width > 750) {
      sidenavEl.classList.remove(SIDENAV_ACTIVE_CLASS);
      gridEl.classList.remove(GRID_NO_SCROLL_CLASS);
    }
  });
}

// Menu open sidenav icon, shown only on mobile
function setMenuClickListener() {
  const menuIcon = document.querySelector('.header__menu');

  menuIcon.addEventListener('click', (e) => {
    toggleClass(sidenavEl, SIDENAV_ACTIVE_CLASS);
    toggleClass(gridEl, GRID_NO_SCROLL_CLASS);
  });
}

// Sidenav close icon
function setSidenavCloseListener() {
  const closeIcon = document.querySelector('.sidenav__brand-close');

  closeIcon.addEventListener('click', (e) => {
    toggleClass(sidenavEl, SIDENAV_ACTIVE_CLASS);
    toggleClass(gridEl, GRID_NO_SCROLL_CLASS);
  });
}
