import type { Config } from "tailwindcss";
import forms from "@tailwindcss/forms";
import typography from "@tailwindcss/typography";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primaryBlack: "#000000",
        neonGreen: "#39FF14", 
        forestGreen: "#228B22",
        emeraldGreen: "#50C878", 
        grayPrimary: "#6C6C6C", 
        graySecondary: "#1A1A1A", 
        orangeAccent: "#F7C084",
        blueAccent: "#7FB3F6", 
      },
      fontFamily: {
        Anaheim: ["Anaheim", "sans-serif"],
        custom: ["Roboto", "sans-serif"],
      },
    },
  },
  plugins: [forms, typography],
};

export default config;
