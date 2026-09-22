import { Link } from "@tanstack/react-router";

interface LogoProps {
  to?: string;
  className?: string;
  showText?: boolean;
}

/**
 * Model Foundry brand mark. We render two `<img>` elements (light + dark) and
 * toggle visibility via the Tailwind `dark:` variant; that avoids any flash on
 * theme change and lets each variant carry the correct ink for its ground.
 * `showText` picks between the horizontal wordmark lockup and the anvil mark.
 */
export function Logo({ to = "/", className = "", showText = true }: LogoProps) {
  const lightSrc = showText ? "/logo-horizontal.svg" : "/mark.svg";
  const darkSrc = showText ? "/logo-horizontal-dark.svg" : "/mark-dark.svg";
  const sizeClass = showText ? "h-9 w-auto" : "h-7 w-7";

  const content = (
    <div className={`flex items-center ${className}`}>
      <img src={lightSrc} alt="Model Foundry" className={`${sizeClass} block dark:hidden`} />
      <img src={darkSrc} alt="Model Foundry" className={`${sizeClass} hidden dark:block`} />
    </div>
  );

  if (to) {
    return (
      <Link to={to} className="hover:opacity-80 transition-opacity">
        {content}
      </Link>
    );
  }

  return content;
}

export default Logo;
