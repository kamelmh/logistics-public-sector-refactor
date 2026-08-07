# Portfolio Deployment Guide

## Deploy to Netlify (Free)

### Option 1: Drag & Drop (Fastest)

1. Go to [https://app.netlify.com](https://app.netlify.com)
2. Sign up with GitHub (free)
3. Drag the `portfolio-site` folder to the deploy area
4. Your site is live at `https://your-site.netlify.app`

### Option 2: Git-Based (Auto-Deploy)

1. Create a new repo on GitHub: `portfolio-site`
2. Push the folder:
   ```bash
   cd C:\Users\Admin\Projects\active\portfolio-site
   git init
   git add .
   git commit -m "Initial portfolio"
   git remote add origin https://github.com/kamelmh/portfolio-site.git
   git push -u origin main
   ```
3. On Netlify, click "New site from Git"
4. Select GitHub → `portfolio-site`
5. Deploy settings: Leave defaults
6. Click "Deploy site"

### Option 3: Custom Domain

1. Buy a domain (e.g., `kamelmahi.dev`)
2. On Netlify, go to Domain Settings
3. Add custom domain
4. Update DNS:
   - Type: CNAME
   - Name: @
   - Value: your-site.netlify.app

---

## Update Contact Form

1. Go to [https://formspree.io](https://formspree.io)
2. Create free account
3. Create new form
4. Copy form ID
5. Replace `YOUR_FORM_ID` in `index.html`

---

## Files

```
portfolio-site/
├── index.html          # Main page
└── README.md           # This file
```

---

**Last Updated**: 2026-07-16
