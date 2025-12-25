### Performance Optimization

- **Turbopack**: Enabled for faster dev server and production builds
- **Image Optimization**: AVIF/WebP formats with responsive srcset (configured in `next.config.ts`)
- Use Next.js `<Image>` component with `width`/`height` or `fill` + `sizes` prop
- External images require `images.remotePatterns` configuration in `next.config.ts`