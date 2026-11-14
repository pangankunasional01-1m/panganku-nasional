/* ========================================
   PANGANKU NASIONAL - MAIN JAVASCRIPT
   ======================================== */

(function() {
  'use strict';

  // ========================================
  // UTILITY FUNCTIONS
  // ========================================
  const $ = (selector, context = document) => context.querySelector(selector);
  const $$ = (selector, context = document) => [...context.querySelectorAll(selector)];

  const throttle = (fn, delay) => {
    let lastCall = 0;
    return (...args) => {
      const now = Date.now();
      if (now - lastCall >= delay) {
        lastCall = now;
        fn(...args);
      }
    };
  };

  const debounce = (fn, delay) => {
    let timeoutId;
    return (...args) => {
      clearTimeout(timeoutId);
      timeoutId = setTimeout(() => fn(...args), delay);
    };
  };

  // ========================================
  // MOBILE NAVIGATION
  // ========================================
  const initMobileNav = () => {
    const toggle = $('.navbar__toggle');
    const menu = $('.navbar__menu');
    
    if (!toggle || !menu) return;

    toggle.addEventListener('click', () => {
      const isOpen = toggle.getAttribute('aria-expanded') === 'true';
      toggle.setAttribute('aria-expanded', !isOpen);
      menu.classList.toggle('is-open');
      document.body.style.overflow = isOpen ? '' : 'hidden';
    });

    // Close on link click
    $$('.navbar__link', menu).forEach(link => {
      link.addEventListener('click', () => {
        toggle.setAttribute('aria-expanded', 'false');
        menu.classList.remove('is-open');
        document.body.style.overflow = '';
      });
    });

    // Close on escape
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && menu.classList.contains('is-open')) {
        toggle.setAttribute('aria-expanded', 'false');
        menu.classList.remove('is-open');
        document.body.style.overflow = '';
        toggle.focus();
      }
    });

    // Close on outside click
    document.addEventListener('click', (e) => {
      if (menu.classList.contains('is-open') && 
          !menu.contains(e.target) && 
          !toggle.contains(e.target)) {
        toggle.setAttribute('aria-expanded', 'false');
        menu.classList.remove('is-open');
        document.body.style.overflow = '';
      }
    });
  };

  // ========================================
  // SMOOTH SCROLL FOR ANCHOR LINKS
  // ========================================
  const initSmoothScroll = () => {
    $$('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', (e) => {
        const href = anchor.getAttribute('href');
        if (href === '#') return;
        
        const target = $(href);
        if (target) {
          e.preventDefault();
          const navbarHeight = $('.navbar')?.offsetHeight || 0;
          const targetPosition = target.getBoundingClientRect().top + window.scrollY - navbarHeight;
          
          window.scrollTo({
            top: targetPosition,
            behavior: 'smooth'
          });
          
          // Update URL without scroll
          history.pushState(null, '', href);
          
          // Focus target for accessibility
          target.setAttribute('tabindex', '-1');
          target.focus({ preventScroll: true });
        }
      });
    });
  };

  // ========================================
  // NAVBAR SCROLL EFFECT
  // ========================================
  const initNavbarScroll = () => {
    const navbar = $('.navbar');
    if (!navbar) return;

    const handleScroll = throttle(() => {
      if (window.scrollY > 50) {
        navbar.style.background = 'rgba(251, 247, 239, 0.95)';
        navbar.style.boxShadow = 'var(--shadow-md)';
      } else {
        navbar.style.background = 'rgba(251, 247, 239, 0.9)';
        navbar.style.boxShadow = 'none';
      }
    }, 100);

    window.addEventListener('scroll', handleScroll, { passive: true });
  };

  // ========================================
  // SCREENSHOTS CAROUSEL
  // ========================================
  const initCarousel = () => {
    const track = $('#carouselTrack');
    const prevBtn = $('#carouselPrev');
    const nextBtn = $('#carouselNext');
    const indicators = $$('.carousel__indicator');
    
    if (!track || !prevBtn || !nextBtn) return;

    let currentIndex = 0;
    const totalSlides = $$('.carousel__slide', track).length;
    let autoPlayInterval;

    const updateCarousel = () => {
      const translateX = -currentIndex * 100;
      track.style.transform = `translateX(${translateX}%)`;
      
      // Update indicators
      indicators.forEach((indicator, index) => {
        indicator.setAttribute('aria-selected', index === currentIndex);
      });
    };

    const goToSlide = (index) => {
      currentIndex = (index + totalSlides) % totalSlides;
      updateCarousel();
      resetAutoPlay();
    };

    const nextSlide = () => goToSlide(currentIndex + 1);
    const prevSlide = () => goToSlide(currentIndex - 1);

    // Button events
    nextBtn.addEventListener('click', nextSlide);
    prevBtn.addEventListener('click', prevSlide);

    // Indicator events
    indicators.forEach((indicator, index) => {
      indicator.addEventListener('click', () => goToSlide(index));
    });

    // Keyboard navigation
    track.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowLeft') prevSlide();
      if (e.key === 'ArrowRight') nextSlide();
    });

    // Touch/swipe support
    let touchStartX = 0;
    let touchEndX = 0;

    track.addEventListener('touchstart', (e) => {
      touchStartX = e.changedTouches[0].screenX;
    }, { passive: true });

    track.addEventListener('touchend', (e) => {
      touchEndX = e.changedTouches[0].screenX;
      handleSwipe();
    }, { passive: true });

    const handleSwipe = () => {
      const swipeThreshold = 50;
      const diff = touchStartX - touchEndX;
      
      if (Math.abs(diff) > swipeThreshold) {
        if (diff > 0) nextSlide();
        else prevSlide();
      }
    };

    // Auto-play
    const startAutoPlay = () => {
      autoPlayInterval = setInterval(nextSlide, 5000);
    };

    const resetAutoPlay = () => {
      clearInterval(autoPlayInterval);
      startAutoPlay();
    };

    // Pause on hover
    const viewport = $('.carousel__viewport');
    if (viewport) {
      viewport.addEventListener('mouseenter', () => clearInterval(autoPlayInterval));
      viewport.addEventListener('mouseleave', startAutoPlay);
    }

    // Initialize
    updateCarousel();
    startAutoPlay();

    // Pause when tab is not visible
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        clearInterval(autoPlayInterval);
      } else {
        startAutoPlay();
      }
    });
  };

  // ========================================
  // INTERSECTION OBSERVER FOR REVEAL ANIMATIONS
  // ========================================
  const initRevealAnimations = () => {
    const observerOptions = {
      root: null,
      rootMargin: '0px 0px -10% 0px',
      threshold: 0.1
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      });
    }, observerOptions);

    // Observe elements with .reveal class
    $$('.reveal').forEach(el => observer.observe(el));

    // Auto-add reveal to common elements
    $$('.feature-card, .user-card, .tech__category, .section-header').forEach((el, index) => {
      el.classList.add('reveal');
      el.style.transitionDelay = `${index * 100}ms`;
      observer.observe(el);
    });
  };

  // ========================================
  // STAT COUNTER ANIMATION
  // ========================================
  const initStatCounters = () => {
    const counters = $$('.hero__stat-number');
    if (!counters.length) return;

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const counter = entry.target;
          const target = parseInt(counter.textContent.replace(/\D/g, ''), 10);
          const suffix = counter.textContent.replace(/[\d,]/g, '');
          const duration = 2000;
          const startTime = Date.now();
          
          const animate = () => {
            const elapsed = Date.now() - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const eased = 1 - Math.pow(1 - progress, 3); // easeOutCubic
            const current = Math.floor(target * eased);
            
            counter.textContent = current.toLocaleString() + suffix;
            
            if (progress < 1) {
              requestAnimationFrame(animate);
            }
          };
          
          animate();
          observer.unobserve(counter);
        }
      });
    }, { threshold: 0.5 });

    counters.forEach(counter => observer.observe(counter));
  };

  // ========================================
  // LAZY LOAD IMAGES
  // ========================================
  const initLazyLoad = () => {
    if (!('IntersectionObserver' in window)) {
      // Fallback for older browsers
      $$('img[loading="lazy"]').forEach(img => {
        img.removeAttribute('loading');
      });
      return;
    }

    const imageObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          if (img.dataset.src) {
            img.src = img.dataset.src;
            img.removeAttribute('data-src');
          }
          img.removeAttribute('loading');
          imageObserver.unobserve(img);
        }
      });
    }, { rootMargin: '50px' });

    $$('img[loading="lazy"]').forEach(img => imageObserver.observe(img));
  };

  // ========================================
  // COPY TO CLIPBOARD (for future use)
  // ========================================
  const initCopyButtons = () => {
    $$('[data-copy]').forEach(btn => {
      btn.addEventListener('click', async () => {
        const text = btn.getAttribute('data-copy');
        try {
          await navigator.clipboard.writeText(text);
          const originalText = btn.textContent;
          btn.textContent = 'Disalin!';
          btn.classList.add('copied');
          setTimeout(() => {
            btn.textContent = originalText;
            btn.classList.remove('copied');
          }, 2000);
        } catch (err) {
          console.error('Copy failed:', err);
        }
      });
    });
  };

  // ========================================
  // INITIALIZATION
  // ========================================
  const init = () => {
    // Wait for DOM ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', init);
      return;
    }

    initMobileNav();
    initSmoothScroll();
    initNavbarScroll();
    initCarousel();
    initRevealAnimations();
    initStatCounters();
    initLazyLoad();
    initCopyButtons();

    // Add loaded class for CSS transitions
    document.body.classList.add('js-loaded');
  };

  // Run init
  init();

  // ========================================
  // EXPOSE FOR DEBUGGING
  // ========================================
  window.PanganKu = {
    version: '1.0.0',
    init
  };

})();