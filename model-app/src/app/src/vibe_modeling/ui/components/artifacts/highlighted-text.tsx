import { useEffect, useState } from "react";
import { PrismAsyncLight as SyntaxHighlighter } from "react-syntax-highlighter";
import sql from "react-syntax-highlighter/dist/esm/languages/prism/sql";
import json from "react-syntax-highlighter/dist/esm/languages/prism/json";
import yaml from "react-syntax-highlighter/dist/esm/languages/prism/yaml";
import python from "react-syntax-highlighter/dist/esm/languages/prism/python";
import turtle from "react-syntax-highlighter/dist/esm/languages/prism/turtle";
import vscDarkPlus from "react-syntax-highlighter/dist/esm/styles/prism/vsc-dark-plus";
import oneLight from "react-syntax-highlighter/dist/esm/styles/prism/one-light";

SyntaxHighlighter.registerLanguage("sql", sql);
SyntaxHighlighter.registerLanguage("json", json);
SyntaxHighlighter.registerLanguage("yaml", yaml);
SyntaxHighlighter.registerLanguage("python", python);
SyntaxHighlighter.registerLanguage("turtle", turtle);

export type HighlightLanguage =
  | "sql"
  | "json"
  | "yaml"
  | "python"
  | "turtle";

function useIsDark(): boolean {
  const [isDark, setIsDark] = useState<boolean>(() => {
    if (typeof document === "undefined") return false;
    return document.documentElement.classList.contains("dark");
  });
  useEffect(() => {
    if (typeof document === "undefined") return;
    const root = document.documentElement;
    const update = () => setIsDark(root.classList.contains("dark"));
    const observer = new MutationObserver(update);
    observer.observe(root, { attributes: true, attributeFilter: ["class"] });
    update();
    return () => observer.disconnect();
  }, []);
  return isDark;
}

export function HighlightedText({
  language,
  source,
  label,
}: {
  language: HighlightLanguage;
  source: string;
  label?: string;
}) {
  const isDark = useIsDark();
  const style = isDark ? vscDarkPlus : oneLight;
  return (
    <div className="space-y-1" data-testid="highlighted-text">
      {label && (
        <p className="text-[10px] text-muted-foreground font-medium uppercase tracking-wide">
          {label}
        </p>
      )}
      <div className="max-h-[min(28rem,70vh)] overflow-auto rounded-md border border-border/60">
        <SyntaxHighlighter
          language={language}
          style={style}
          customStyle={{
            margin: 0,
            padding: "1rem",
            fontSize: "0.75rem",
            lineHeight: "1.5",
            background: "transparent",
          }}
          codeTagProps={{
            style: { fontFamily: "var(--font-mono, ui-monospace, monospace)" },
          }}
          wrapLongLines
        >
          {source}
        </SyntaxHighlighter>
      </div>
    </div>
  );
}
