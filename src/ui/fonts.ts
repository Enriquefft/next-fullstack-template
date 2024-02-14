import localFont from "next/font/local";
import { Inter } from "next/font/google";

export const inter = Inter({ subsets: ["latin"] });

export const bigNoodleTitling = localFont({
  // TODO: Preferably, this should be an absolute path to the font file
  src: "../../public/fonts/big_noodle_titling.ttf",
  display: "swap",
});
