-- PostgreSQL DDL untuk platform e-commerce multi-vendor

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE user_role AS ENUM ('BUYER', 'SELLER', 'ADMIN');
CREATE TYPE store_status AS ENUM ('PENDING', 'ACTIVE', 'REJECTED', 'SUSPENDED');
CREATE TYPE product_status AS ENUM ('ACTIVE', 'DRAFT', 'OUT_OF_STOCK', 'INACTIVE');
CREATE TYPE order_status AS ENUM ('UNPAID', 'PAID', 'PACKING', 'SHIPPED', 'DELIVERED', 'COMPLETED', 'CANCELLED', 'RETURNED');
CREATE TYPE payment_method AS ENUM ('VA', 'EWALLET', 'QRIS', 'COD');
CREATE TYPE payment_status AS ENUM ('PENDING', 'PAID', 'FAILED', 'REFUNDED');
CREATE TYPE wallet_tx_type AS ENUM ('INCOME', 'WITHDRAW', 'COMMISSION', 'REFUND');
CREATE TYPE wallet_tx_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'COMPLETED');
CREATE TYPE courier AS ENUM ('JNE', 'JT', 'SICEPAT', 'OTHER');

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  phone TEXT,
  role user_role NOT NULL,
  email_verified BOOLEAN NOT NULL DEFAULT FALSE,
  otp_code TEXT,
  otp_expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE buyer_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  address TEXT,
  city_id TEXT,
  postal_code TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE stores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  store_name TEXT NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  city_id TEXT NOT NULL,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  bank_account_name TEXT NOT NULL,
  bank_account_number TEXT NOT NULL,
  bank_name TEXT NOT NULL,
  supported_couriers courier[] NOT NULL DEFAULT ARRAY[]::courier[],
  balance BIGINT NOT NULL DEFAULT 0,
  status store_status NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category_id TEXT NOT NULL,
  weight INT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  status product_status NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE product_variants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  color TEXT NOT NULL,
  color_hex TEXT,
  size TEXT NOT NULL,
  price INT NOT NULL,
  stock INT NOT NULL,
  sku TEXT NOT NULL UNIQUE,
  extra_price INT NOT NULL DEFAULT 0,
  weight INT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE carts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_variant_id UUID NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
  quantity INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE (user_id, product_variant_id)
);

CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number TEXT NOT NULL UNIQUE,
  buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE RESTRICT,
  total_price INT NOT NULL,
  shipping_cost INT NOT NULL,
  subtotal INT NOT NULL,
  discount INT NOT NULL DEFAULT 0,
  platform_fee INT NOT NULL DEFAULT 0,
  status order_status NOT NULL,
  tracking_number TEXT,
  courier TEXT,
  payment_method payment_method NOT NULL,
  payment_status payment_status NOT NULL,
  shipping_address TEXT NOT NULL,
  city_id TEXT NOT NULL,
  district_id TEXT NOT NULL,
  postal_code TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_variant_id UUID NOT NULL REFERENCES product_variants(id) ON DELETE RESTRICT,
  quantity INT NOT NULL,
  price_at_purchase INT NOT NULL,
  weight INT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE wallet_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  amount INT NOT NULL,
  type wallet_tx_type NOT NULL,
  status wallet_tx_status NOT NULL,
  reference TEXT,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_item_id UUID NOT NULL UNIQUE REFERENCES order_items(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  media_urls TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_products_category_name ON products (category_id, name);
CREATE INDEX idx_product_variants_sku ON product_variants (sku);
CREATE INDEX idx_orders_status ON orders (status);
CREATE INDEX idx_orders_buyer_store ON orders (buyer_id, store_id);
CREATE INDEX idx_wallet_transactions_store ON wallet_transactions (store_id);
CREATE INDEX idx_reviews_user ON reviews (user_id);
