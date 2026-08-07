# Deploy to Netlify

## Option 1: Drag-and-Drop (2 minutes)

1. Go to https://app.netlify.com/drop
2. Open File Explorer to `C:\Users\Admin\Projects\active\portfolio-site\`
3. Drag the entire `portfolio-site` folder to the Netlify drop zone
4. Wait for deploy (usually 30-60 seconds)
5. Copy your new URL (something like `https://random-name.netlify.app`)

## Option 2: Netlify CLI (if installed)

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login to Netlify
netlify login

# Deploy from portfolio-site folder
cd C:\Users\Admin\Projects\active\portfolio-site
netlify deploy --prod
```

## After Deployment

1. Test the site at your new URL
2. Check all screenshots load
3. Test the WhatsApp and email links
4. Update your LinkedIn/Upwork/Fiverr with the new URL

## Custom Domain (optional)

If you want a custom domain like `kamelmahi.com`:
1. Buy domain from Namecheap/GoDaddy ($8-12/year)
2. In Netlify dashboard → Domain Settings → Add custom domain
3. Update DNS records as shown by Netlify
4. Wait for SSL certificate (automatic, ~15 minutes)
