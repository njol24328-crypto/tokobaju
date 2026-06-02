# Architecture Blueprint — Multi-Vendor E-Commerce Marketplace

## 1. Monorepo vs Polyrepo

### 1.1. Rekomendasi: Monorepo (TurboRepo)
Monorepo paling ideal untuk platform enterprise ini karena:
- Shared code konsisten di antara `buyer`, `seller`, `admin`, dan `backend`
- Type safety mudah dijaga dengan `TypeScript`
- Satu CI/CD pipeline dapat mengelola build, test, dan deploy multi-app
- Reuse utilities, enum, contract, dan API client di `packages`

### 1.2. Alternatif: Polyrepo
Gunakan polyrepo jika:
- Tim totalnya sangat besar dan terpisah secara organisasi
- Setiap aplikasi punya lifecycle, release, dan tim ownership berbeda
- Infrastruktur repository management sudah mature

---

## 2. Monorepo Folder Structure

```
/ (root)
├── apps
│   ├── buyer-app
│   │   ├── public
│   │   ├── src
│   │   │   ├── app
│   │   │   ├── components
│   │   │   ├── features
│   │   │   ├── hooks
│   │   │   ├── lib
│   │   │   ├── pages
│   │   │   ├── services
│   │   │   ├── stores
│   │   │   └── styles
│   │   ├── next.config.mjs
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── seller-center
│   │   ├── public
│   │   ├── src
│   │   │   ├── app
│   │   │   ├── components
│   │   │   ├── pages
│   │   │   ├── modules
│   │   │   ├── services
│   │   │   ├── stores
│   │   │   └── styles
│   │   ├── next.config.mjs
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── admin-dashboard
│       ├── public
│       ├── src
│       │   ├── app
│       │   ├── components
│       │   ├── pages
│       │   ├── modules
│       │   ├── services
│       │   ├── stores
│       │   └── styles
│       ├── next.config.mjs
│       ├── package.json
│       └── tsconfig.json
├── packages
│   ├── api-client
│   │   ├── src
│   │   │   ├── index.ts
│   │   │   ├── auth.ts
│   │   │   ├── buyer.ts
│   │   │   ├── seller.ts
│   │   │   ├── admin.ts
│   │   │   └── types.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── design-system
│   │   ├── src
│   │   │   ├── components
│   │   │   ├── theme
│   │   │   └── utils
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── shared-types
│   │   ├── src
│   │   │   ├── domain.ts
│   │   │   └── enums.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── utils
│       ├── src
│       │   ├── date.ts
│       │   ├── validation.ts
│       │   └── logger.ts
│       ├── package.json
│       └── tsconfig.json
├── services
│   ├── api
│   │   ├── prisma
│   │   │   └── schema.prisma
│   │   ├── src
│   │   │   ├── app.module.ts
│   │   │   ├── main.ts
│   │   │   ├── modules
│   │   │   │   ├── auth
│   │   │   │   ├── catalog
│   │   │   │   ├── cart
│   │   │   │   ├── checkout
│   │   │   │   ├── orders
│   │   │   │   ├── payments
│   │   │   │   ├── logistics
│   │   │   │   ├── reviews
│   │   │   │   ├── sellers
│   │   │   │   └── admin
│   │   │   ├── config
│   │   │   ├── guards
│   │   │   ├── interceptors
│   │   │   └── pipes
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── Dockerfile
│   └── worker
│       ├── src
│       │   ├── queues
│       │   ├── processors
│       │   ├── jobs
│       │   └── workers.ts
│       ├── package.json
│       ├── tsconfig.json
│       └── Dockerfile
├── infra
│   ├── terraform
│   │   ├── aws
│   │   ├── gcp
│   │   └── modules
│   ├── k8s
│   │   ├── buyer-app.yaml
│   │   ├── seller-center.yaml
│   │   ├── admin-dashboard.yaml
│   │   ├── api-deployment.yaml
│   │   └── worker-deployment.yaml
│   ├── docker
│   │   ├── docker-compose.yml
│   │   └── nginx.conf
│   ├── cicd
│   │   ├── github-actions.yml
│   │   └── pipeline.yml
│   └── scripts
│       ├── bootstrap.sh
│       ├── migrate.sh
│       └── deploy.sh
├── docs
│   ├── architecture-blueprint.md
│   └── deployment.md
├── .gitignore
├── package.json
├── pnpm-workspace.yaml
├── turbo.json
└── README.md
```

### 2.1. Penjelasan Top-Level
- `apps/`: UI apps yang dideploy terpisah, tapi tetap dalam satu repo
- `packages/`: kode bersama seperti SDK API, desain sistem, utilitas, dan tipe bersama
- `services/`: backend dan worker/queue terpisah
- `infra/`: konfigurasi deployment, IaC, pipeline
- `docs/`: dokumentasi arsitektur, runbooks, dan blueprint teknis

---

## 3. Contoh Konfigurasi TurboRepo

### 3.1. `package.json` root

```json
{
  "name": "tokobaju-monorepo",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*",
    "services/*"
  ],
  "devDependencies": {
    "turbo": "^1.10.0",
    "typescript": "^5.5.0",
    "prettier": "^3.0.0"
  },
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "lint": "turbo lint",
    "test": "turbo test"
  }
}
```

### 3.2. `turbo.json`

```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "dev": {
      "dependsOn": ["^dev"],
      "cache": false
    },
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**","build/**"]
    },
    "lint": {
      "outputs": []
    },
    "test": {
      "outputs": []
    },
    "migrate": {
      "cache": false
    }
  }
}
```

### 3.3. `pnpm-workspace.yaml`

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
  - 'services/*'
```

---

## 4. Struktur Tiap Aplikasi

### 4.1. Buyer App
- `features/catalog`: katalog, filter, search
- `features/cart`: keranjang multi-toko
- `features/checkout`: pembayaran, ongkir, review pesanan
- `services/api`: adapter ke backend API Gateway
- `components/ui`: reusable component
- `lib/auth`: JWT/OAuth login
- `pages` / `app`: halaman buyer

### 4.2. Seller Center
- `features/store-onboarding`
- `features/product-management`
- `features/order-management`
- `features/wallet`
- `features/analytics`
- `services/api`
- `pages` / `app`

### 4.3. Admin Dashboard
- `features/dashboard`
- `features/kyc`
- `features/commission`
- `features/dispute`
- `features/campaigns`
- `services/api`

---

## 5. Struktur Backend Modular

### 5.1. `services/api/src/modules`

- `auth/`
- `users/`
- `stores/`
- `catalog/`
- `products/`
- `cart/`
- `orders/`
- `payments/`
- `logistics/`
- `reviews/`
- `admin/`
- `analytics/`

### 5.2. Security dan shared infrastructure
- `config/`: env loading, rate limiting, CORS, security headers
- `guards/`: RBAC, JWT, ownership
- `interceptors/`: auditing, response formatting
- `services/`: payment provider, logistics, notification, document storage

---

## 6. Deployment Mapping

### 6.1. Per-app deployment
- `buyer-app`: CDN / Vercel / static hosting
- `seller-center`: CDN / Vercel / static hosting
- `admin-dashboard`: CDN / Vercel / static hosting
- `api`: container / Kubernetes / Fargate
- `worker`: container / Kubernetes / Fargate

### 6.2. Domains
- `klambiku.com` → buyer app
- `seller.klambiku.com` → seller dashboard
- `admin-core.klambiku.com` → admin dashboard
- `api.klambiku.com` → backend API gateway

### 6.3. Infra
- `infra/docker/docker-compose.yml`: local dev stack
- `infra/k8s`: production manifest
- `infra/terraform`: cloud resources
- `infra/cicd`: GitHub Actions / pipeline

---

## 7. Kenapa Struktur Ini Baik

- Modular dan scalable: setiap domain app dipisah jelas
- Reusable shared packages: `packages/shared-types`, `packages/api-client`
- Backend domain-driven: `services/api/src/modules`
- Deployment independen: frontend bisa di-deploy per domain
- CI/CD unified: satu monorepo jalankan test/build parallel

---

## 8. Next Step

Jika Anda ingin, saya bisa langsung membuat:
1. scaffold `package.json`, `turbo.json`, dan `pnpm-workspace.yaml`,
2. `infra/docker/docker-compose.yml` minimal untuk local dev,
3. starter `services/api` dan `apps/buyer-app` skeleton.
