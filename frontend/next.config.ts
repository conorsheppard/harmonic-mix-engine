import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  reactCompiler: true,
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: `${process.env.BACKEND_URL || "http://harmonic-mix-engine:8080"}/:path*`,
      },
    ];
  },
};

export default nextConfig;
