// Attunetion Marketing Website - Minimal JavaScript
// Smooth scrolling and accessibility enhancements

(function() {
    'use strict';

    // Smooth scroll for anchor links (enhancement for browsers that need it)
    document.addEventListener('DOMContentLoaded', function() {
        // Handle smooth scrolling for anchor links
        const anchorLinks = document.querySelectorAll('a[href^="#"]');
        
        anchorLinks.forEach(function(link) {
            link.addEventListener('click', function(e) {
                const href = this.getAttribute('href');
                
                // Skip if it's just "#"
                if (href === '#') {
                    return;
                }
                
                const target = document.querySelector(href);
                
                if (target) {
                    e.preventDefault();
                    
                    // Calculate offset for sticky header
                    const header = document.querySelector('header');
                    const headerHeight = header ? header.offsetHeight : 0;
                    const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - headerHeight;
                    
                    window.scrollTo({
                        top: targetPosition,
                        behavior: 'smooth'
                    });
                }
            });
        });

        // Skip link functionality enhancement
        const skipLink = document.querySelector('.skip-link');
        if (skipLink) {
            skipLink.addEventListener('click', function(e) {
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    e.preventDefault();
                    target.setAttribute('tabindex', '-1');
                    target.focus();
                    window.scrollTo({
                        top: 0,
                        behavior: 'smooth'
                    });
                    
                    // Remove tabindex after focus to avoid tab navigation issues
                    setTimeout(function() {
                        target.removeAttribute('tabindex');
                    }, 1000);
                }
            });
        }

        // Respect reduced motion preference
        const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        if (prefersReducedMotion) {
            // Disable smooth scrolling if user prefers reduced motion
            document.documentElement.style.scrollBehavior = 'auto';
        }
    });

    // Console message for developers
    console.log('%cAttunetion', 'font-size: 20px; font-weight: bold; color: #7C9A9B;');
    console.log('%cStay focused on what matters most.', 'color: #6B7280;');
})();

