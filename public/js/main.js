// TalentForge — Main Client-Side JavaScript

document.addEventListener('DOMContentLoaded', function () {
    // Logout handler
    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', async function (e) {
            e.preventDefault();
            try {
                await fetch('/api/v1/auth/logout', { method: 'POST' });
            } catch (err) {
                // ignore
            }
            document.cookie = 'token=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
            window.location.href = '/';
        });
    }

    // Login form handler
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', async function (e) {
            e.preventDefault();
            const loginBtn = document.getElementById('loginBtn');
            const errorDiv = document.getElementById('loginError');
            loginBtn.disabled = true;
            loginBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Logging in...';
            errorDiv.classList.add('d-none');

            try {
                const res = await fetch('/api/v1/auth/login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        email: document.getElementById('email').value,
                        password: document.getElementById('password').value
                    })
                });
                const data = await res.json();

                if (res.ok) {
                    window.location.href = '/';
                } else {
                    errorDiv.textContent = data.error || 'Login failed';
                    errorDiv.classList.remove('d-none');
                }
            } catch (err) {
                errorDiv.textContent = 'Network error. Please try again.';
                errorDiv.classList.remove('d-none');
            }

            loginBtn.disabled = false;
            loginBtn.innerHTML = '<i class="bi bi-box-arrow-in-right me-1"></i> Log In';
        });
    }

    // Register form handler
    const registerForm = document.getElementById('registerForm');
    if (registerForm) {
        registerForm.addEventListener('submit', async function (e) {
            e.preventDefault();
            const registerBtn = document.getElementById('registerBtn');
            const errorDiv = document.getElementById('registerError');
            const successDiv = document.getElementById('registerSuccess');
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;

            errorDiv.classList.add('d-none');
            successDiv.classList.add('d-none');

            if (password !== confirmPassword) {
                errorDiv.textContent = 'Passwords do not match';
                errorDiv.classList.remove('d-none');
                return;
            }

            registerBtn.disabled = true;
            registerBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Creating account...';

            try {
                const res = await fetch('/api/v1/auth/register', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        name: document.getElementById('name').value,
                        email: document.getElementById('email').value,
                        password: password
                    })
                });
                const data = await res.json();

                if (res.ok) {
                    window.location.href = '/';
                } else {
                    errorDiv.textContent = data.error || 'Registration failed';
                    errorDiv.classList.remove('d-none');
                }
            } catch (err) {
                errorDiv.textContent = 'Network error. Please try again.';
                errorDiv.classList.remove('d-none');
            }

            registerBtn.disabled = false;
            registerBtn.innerHTML = '<i class="bi bi-rocket-takeoff me-1"></i> Create Account';
        });
    }
});
