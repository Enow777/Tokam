import './style.css'

document.querySelector('#download-apk').addEventListener('click', () => {
  // In a real scenario, this would point to the actual APK file hosted somewhere
  // Since we're demonstrating the landing page, we'll show an alert or trigger a placeholder download
  alert('Downloading Tokam Accessibility Overlay (tokam_v1.0.0.apk)...');
});

// Smooth scroll for nav links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth'
            });
        }
    });
});
