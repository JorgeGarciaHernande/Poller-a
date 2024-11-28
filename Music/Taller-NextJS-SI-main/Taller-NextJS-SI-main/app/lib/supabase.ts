import { createClient } from "@supabase/supabase-js";

// Claves directamente incluidas (No recomendado para producción)
const supabaseUrl = "https://wfjpkrpjhtxetpzxwvhy.supabase.co";
const supabaseAnonKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmanBrcnBqaHR4ZXRwenh3dmh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI1OTYyNzMsImV4cCI6MjA0ODE3MjI3M30.dHU0aI7Fsh-U4zfT6DZV6JqRnpkgzvJwvFRLXjUQUkc";

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
