"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import { toPng } from "html-to-image";

// ─── Canvas & Export Dimensions ─────────────────────────────────────────────
const W = 1284;
const H = 2778;

const IPHONE_SIZES = [
  { label: "1284×2778", w: 1284, h: 2778 },
  { label: "2778×1284", w: 2778, h: 1284 },
  { label: "1242×2688", w: 1242, h: 2688 },
  { label: "2688×1242", w: 2688, h: 1242 },
] as const;

// ─── Mockup Measurements ────────────────────────────────────────────────────
const MK_W = 1022;
const MK_H = 2082;
const MK_RATIO = MK_W / MK_H;
const SC_L = (52 / MK_W) * 100;
const SC_T = (46 / MK_H) * 100;
const SC_W = (918 / MK_W) * 100;
const SC_H = (1990 / MK_H) * 100;
const SC_RX = (126 / 918) * 100;
const SC_RY = (126 / 1990) * 100;

// ─── Width Formula ──────────────────────────────────────────────────────────
function phoneW(cW: number, cH: number, clamp = 0.84) {
  return Math.min(clamp, 0.72 * (cH / cW) * MK_RATIO);
}

// ─── Image Preload Cache ────────────────────────────────────────────────────
const IMAGE_PATHS = [
  "/mockup.png",
  "/app-icon.png",
  "/screenshots/topic.png",
  "/screenshots/guess.png",
  "/screenshots/setup.png",
  "/screenshots/results.png",
  "/screenshots/analysis.png",
];

const imageCache: Record<string, string> = {};

async function preloadAllImages() {
  await Promise.all(
    IMAGE_PATHS.map(async (path) => {
      const resp = await fetch(path);
      const blob = await resp.blob();
      const dataUrl = await new Promise<string>((resolve) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result as string);
        reader.readAsDataURL(blob);
      });
      imageCache[path] = dataUrl;
    })
  );
}

function img(path: string): string {
  return imageCache[path] || path;
}

// ─── Theme ──────────────────────────────────────────────────────────────────
const theme = {
  accent: "#FF8C00",
  accentSecondary: "#FFB347",
  textPrimary: "#1A1A1A",
  textSecondary: "#6B7280",
  bgCream: "#FFF8F0",
  bgWhite: "#FFFFFF",
  gold: "#F59E0B",
  pink: "#FF6B8A",
};

// ─── Device Frame ───────────────────────────────────────────────────────────
function Phone({
  src,
  alt,
  style,
}: {
  src: string;
  alt: string;
  style?: React.CSSProperties;
}) {
  return (
    <div
      style={{
        position: "relative",
        aspectRatio: `${MK_W}/${MK_H}`,
        ...style,
      }}
    >
      <img
        src={img("/mockup.png")}
        alt=""
        style={{ display: "block", width: "100%", height: "100%" }}
        draggable={false}
      />
      <div
        style={{
          position: "absolute",
          zIndex: 10,
          overflow: "hidden",
          left: `${SC_L}%`,
          top: `${SC_T}%`,
          width: `${SC_W}%`,
          height: `${SC_H}%`,
          borderRadius: `${SC_RX}% / ${SC_RY}%`,
        }}
      >
        <img
          src={src}
          alt={alt}
          style={{
            display: "block",
            width: "100%",
            height: "100%",
            objectFit: "cover",
            objectPosition: "top",
          }}
          draggable={false}
        />
      </div>
    </div>
  );
}

// ─── Caption ────────────────────────────────────────────────────────────────
function Caption({
  cW,
  label,
  headline,
  color = theme.textPrimary,
  labelColor = theme.accent,
  style,
}: {
  cW: number;
  label: string;
  headline: React.ReactNode;
  color?: string;
  labelColor?: string;
  style?: React.CSSProperties;
}) {
  return (
    <div
      style={{
        position: "absolute",
        top: cW * 0.06,
        left: "50%",
        transform: "translateX(-50%)",
        textAlign: "center",
        width: "88%",
        zIndex: 20,
        ...style,
      }}
    >
      <div
        style={{
          fontSize: cW * 0.032,
          fontWeight: 600,
          color: labelColor,
          letterSpacing: "0.12em",
          marginBottom: cW * 0.02,
        }}
      >
        {label}
      </div>
      <div
        style={{
          fontSize: cW * 0.095,
          fontWeight: 700,
          color,
          lineHeight: 1.15,
        }}
      >
        {headline}
      </div>
    </div>
  );
}

// ─── Decorative Blob ────────────────────────────────────────────────────────
function Blob({
  size,
  color,
  top,
  left,
  right,
  bottom,
  blur = 80,
}: {
  size: number;
  color: string;
  top?: string;
  left?: string;
  right?: string;
  bottom?: string;
  blur?: number;
}) {
  return (
    <div
      style={{
        position: "absolute",
        width: size,
        height: size,
        borderRadius: "50%",
        background: color,
        filter: `blur(${blur}px)`,
        opacity: 0.35,
        top,
        left,
        right,
        bottom,
        pointerEvents: "none",
      }}
    />
  );
}

// ─── Slide Definitions ──────────────────────────────────────────────────────
type SlideProps = { cW: number; cH: number };
type SlideDef = { id: string; component: (p: SlideProps) => React.ReactNode };

const SLIDES: SlideDef[] = [
  // ── Slide 1: Hero ─────────────────────────────────────────────────────────
  {
    id: "hero",
    component: ({ cW, cH }) => {
      const fw = phoneW(cW, cH) * 100;
      return (
        <div
          style={{
            width: "100%",
            height: "100%",
            position: "relative",
            background: `linear-gradient(180deg, ${theme.bgCream} 0%, #FFE8CC 50%, #FFD6A8 100%)`,
            overflow: "hidden",
          }}
        >
          <Blob size={cW * 0.6} color={theme.accent} top="-10%" right="-20%" blur={120} />
          <Blob size={cW * 0.4} color={theme.pink} bottom="20%" left="-15%" blur={100} />

          {/* App Icon + Headline */}
          <div
            style={{
              position: "absolute",
              top: cW * 0.06,
              left: "50%",
              transform: "translateX(-50%)",
              zIndex: 20,
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              gap: cW * 0.025,
            }}
          >
            <img
              src={img("/app-icon.png")}
              alt="GuessRank"
              style={{
                width: cW * 0.14,
                height: cW * 0.14,
                borderRadius: cW * 0.03,
                boxShadow: "0 8px 32px rgba(255,140,0,0.25)",
              }}
              draggable={false}
            />
            <div
              style={{
                fontSize: cW * 0.03,
                fontWeight: 600,
                color: theme.accent,
                letterSpacing: "0.12em",
              }}
            >
              ランキング予想ゲーム
            </div>
            <div
              style={{
                fontSize: cW * 0.095,
                fontWeight: 700,
                color: theme.textPrimary,
                lineHeight: 1.15,
                textAlign: "center",
              }}
            >
              友達の本音、
              <br />
              当てられる？
            </div>
          </div>

          <Phone
            src={img("/screenshots/topic.png")}
            alt="お題画面"
            style={{
              position: "absolute",
              bottom: 0,
              width: `${fw}%`,
              left: "50%",
              transform: "translateX(-50%) translateY(13%)",
            }}
          />
        </div>
      );
    },
  },

  // ── Slide 2: Differentiator ───────────────────────────────────────────────
  {
    id: "guess",
    component: ({ cW, cH }) => {
      const fw = phoneW(cW, cH) * 100;
      return (
        <div
          style={{
            width: "100%",
            height: "100%",
            position: "relative",
            background: `linear-gradient(160deg, #FFF0E0 0%, ${theme.bgCream} 40%, #FFF5EB 100%)`,
            overflow: "hidden",
          }}
        >
          <Blob size={cW * 0.5} color="#FFD700" top="5%" left="-10%" blur={100} />
          <Blob size={cW * 0.35} color={theme.accent} bottom="30%" right="-10%" blur={90} />

          <Caption
            cW={cW}
            label="予想していく楽しさ"
            headline={
              <>
                え、そっちが
                <br />
                1位なの！？
              </>
            }
          />

          <Phone
            src={img("/screenshots/guess.png")}
            alt="予想画面"
            style={{
              position: "absolute",
              bottom: 0,
              width: `${fw}%`,
              left: "55%",
              transform: "translateX(-50%) translateY(13%)",
            }}
          />
        </div>
      );
    },
  },

  // ── Slide 3: Speed (contrast dark slide) ──────────────────────────────────
  {
    id: "setup",
    component: ({ cW, cH }) => {
      const fw = phoneW(cW, cH) * 100;
      return (
        <div
          style={{
            width: "100%",
            height: "100%",
            position: "relative",
            background: "linear-gradient(180deg, #1A1A2E 0%, #16213E 50%, #0F3460 100%)",
            overflow: "hidden",
          }}
        >
          <Blob size={cW * 0.5} color={theme.accent} top="-5%" right="-15%" blur={120} />
          <Blob size={cW * 0.4} color="#FFD700" bottom="25%" left="-20%" blur={110} />

          <Caption
            cW={cW}
            label="準備ゼロ"
            headline={
              <>
                30秒で
                <br />
                ゲーム開始
              </>
            }
            color="#FFFFFF"
            labelColor={theme.accentSecondary}
          />

          <Phone
            src={img("/screenshots/setup.png")}
            alt="ゲーム設定"
            style={{
              position: "absolute",
              bottom: 0,
              width: `${fw}%`,
              left: "50%",
              transform: "translateX(-50%) translateY(13%)",
            }}
          />
        </div>
      );
    },
  },

  // ── Slide 4: Everyone ─────────────────────────────────────────────────────
  {
    id: "results",
    component: ({ cW, cH }) => {
      const fw = phoneW(cW, cH, 0.78) * 100;
      return (
        <div
          style={{
            width: "100%",
            height: "100%",
            position: "relative",
            background: `linear-gradient(170deg, ${theme.bgCream} 0%, #FFECD2 45%, #FCE1C8 100%)`,
            overflow: "hidden",
          }}
        >
          <Blob size={cW * 0.45} color={theme.pink} top="10%" right="-15%" blur={100} />
          <Blob size={cW * 0.5} color={theme.accent} bottom="15%" left="-20%" blur={110} />

          <Caption
            cW={cW}
            label="1台でOK"
            headline={
              <>
                みんなで
                <br />
                端末を回すだけ
              </>
            }
          />

          <Phone
            src={img("/screenshots/results.png")}
            alt="ゲーム結果"
            style={{
              position: "absolute",
              bottom: 0,
              width: `${fw}%`,
              left: "45%",
              transform: "translateX(-50%) translateY(13%)",
            }}
          />
        </div>
      );
    },
  },

  // ── Slide 5: Analysis / More ──────────────────────────────────────────────
  {
    id: "analysis",
    component: ({ cW, cH }) => {
      const fw = phoneW(cW, cH, 0.72) * 100;
      const pillStyle: React.CSSProperties = {
        display: "inline-block",
        padding: `${cW * 0.012}px ${cW * 0.028}px`,
        borderRadius: cW * 0.02,
        fontSize: cW * 0.028,
        fontWeight: 600,
        background: "rgba(255,140,0,0.12)",
        color: theme.accent,
        margin: `0 ${cW * 0.008}px ${cW * 0.012}px 0`,
      };
      return (
        <div
          style={{
            width: "100%",
            height: "100%",
            position: "relative",
            background: `linear-gradient(180deg, #FFF5EB 0%, ${theme.bgCream} 40%, #FFE8D6 100%)`,
            overflow: "hidden",
          }}
        >
          <Blob size={cW * 0.45} color="#FFD700" top="-5%" left="10%" blur={100} />
          <Blob size={cW * 0.35} color={theme.pink} bottom="40%" right="-10%" blur={90} />

          <Caption
            cW={cW}
            label="もっと楽しく"
            headline={
              <>
                お題はいつでも
                <br />
                変更OK
              </>
            }
          />

          <Phone
            src={img("/screenshots/analysis.png")}
            alt="分析画面"
            style={{
              position: "absolute",
              bottom: 0,
              width: `${fw}%`,
              left: "50%",
              transform: "translateX(-50%) translateY(13%)",
            }}
          />

          {/* Feature pills */}
          <div
            style={{
              position: "absolute",
              bottom: cH * 0.04,
              left: "50%",
              transform: "translateX(-50%)",
              width: "80%",
              textAlign: "center",
              zIndex: 20,
            }}
          >
            <span style={pillStyle}>分析機能</span>
            <span style={pillStyle}>ゲーム履歴</span>
            <span style={pillStyle}>難易度設定</span>
            <span style={pillStyle}>ジャンル選択</span>
          </div>
        </div>
      );
    },
  },
];

// ─── Screenshot Preview ─────────────────────────────────────────────────────
function ScreenshotPreview({
  slide,
  cW,
  cH,
  exportRef,
}: {
  slide: SlideDef;
  cW: number;
  cH: number;
  exportRef: (el: HTMLDivElement | null) => void;
}) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [scale, setScale] = useState(0.15);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;
    const ro = new ResizeObserver((entries) => {
      const { width: boxW, height: boxH } = entries[0].contentRect;
      const s = Math.min(boxW / cW, boxH / cH);
      setScale(s);
    });
    ro.observe(container);
    return () => ro.disconnect();
  }, [cW, cH]);

  return (
    <div
      ref={containerRef}
      style={{
        aspectRatio: `${cW}/${cH}`,
        width: "100%",
        position: "relative",
        overflow: "hidden",
        borderRadius: 12,
        border: "1px solid #e5e7eb",
        background: "#f9fafb",
      }}
    >
      <div
        style={{
          width: cW,
          height: cH,
          transform: `scale(${scale})`,
          transformOrigin: "top left",
          position: "absolute",
          top: 0,
          left: 0,
        }}
      >
        <div ref={exportRef} style={{ width: cW, height: cH }}>
          {slide.component({ cW, cH })}
        </div>
      </div>
    </div>
  );
}

// ─── Main Page ──────────────────────────────────────────────────────────────
export default function ScreenshotsPage() {
  const [ready, setReady] = useState(false);
  const [sizeIdx, setSizeIdx] = useState(0);
  const [exporting, setExporting] = useState<string | null>(null);

  const exportRefs = useRef<(HTMLDivElement | null)[]>([]);

  useEffect(() => {
    preloadAllImages().then(() => setReady(true));
  }, []);

  const exportAll = useCallback(async () => {
    const size = IPHONE_SIZES[sizeIdx];
    for (let i = 0; i < SLIDES.length; i++) {
      setExporting(`${i + 1}/${SLIDES.length}`);
      const el = exportRefs.current[i];
      if (!el) continue;

      // Move on-screen for capture
      el.style.position = "fixed";
      el.style.left = "0px";
      el.style.top = "0px";
      el.style.zIndex = "-1";

      const opts = { width: size.w, height: size.h, pixelRatio: 1, cacheBust: true };
      // Double call trick
      await toPng(el, opts);
      const dataUrl = await toPng(el, opts);

      // Restore
      el.style.position = "";
      el.style.left = "";
      el.style.top = "";
      el.style.zIndex = "";

      const a = document.createElement("a");
      a.href = dataUrl;
      a.download = `${String(i + 1).padStart(2, "0")}-${SLIDES[i].id}-${size.w}x${size.h}.png`;
      a.click();
      await new Promise((r) => setTimeout(r, 300));
    }
    setExporting(null);
  }, [sizeIdx]);

  if (!ready) {
    return (
      <div
        style={{
          minHeight: "100vh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          background: "#f3f4f6",
          fontSize: 18,
          color: "#6b7280",
        }}
      >
        Loading images...
      </div>
    );
  }

  return (
    <div
      style={{
        minHeight: "100vh",
        background: "#f3f4f6",
        position: "relative",
        overflowX: "hidden",
      }}
    >
      {/* Toolbar */}
      <div
        style={{
          position: "sticky",
          top: 0,
          zIndex: 50,
          background: "white",
          borderBottom: "1px solid #e5e7eb",
          display: "flex",
          alignItems: "center",
        }}
      >
        <div
          style={{
            flex: 1,
            display: "flex",
            alignItems: "center",
            gap: 10,
            padding: "10px 16px",
            overflowX: "auto",
            minWidth: 0,
          }}
        >
          <span
            style={{
              fontWeight: 700,
              fontSize: 14,
              whiteSpace: "nowrap",
              color: theme.textPrimary,
            }}
          >
            GuessRank · Screenshots
          </span>

          <select
            value={sizeIdx}
            onChange={(e) => setSizeIdx(Number(e.target.value))}
            style={{
              fontSize: 12,
              border: "1px solid #e5e7eb",
              borderRadius: 6,
              padding: "5px 10px",
            }}
          >
            {IPHONE_SIZES.map((s, i) => (
              <option key={i} value={i}>
                {s.label} — {s.w}x{s.h}
              </option>
            ))}
          </select>
        </div>

        <div
          style={{
            flexShrink: 0,
            padding: "10px 16px",
            borderLeft: "1px solid #e5e7eb",
          }}
        >
          <button
            onClick={exportAll}
            disabled={!!exporting}
            style={{
              padding: "7px 20px",
              background: exporting ? "#FFB347" : theme.accent,
              color: "white",
              border: "none",
              borderRadius: 8,
              fontSize: 12,
              fontWeight: 600,
              cursor: exporting ? "default" : "pointer",
              whiteSpace: "nowrap",
            }}
          >
            {exporting ? `Exporting... ${exporting}` : "Export All"}
          </button>
        </div>
      </div>

      {/* Grid */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))",
          gap: 20,
          padding: 24,
          maxWidth: 1600,
          margin: "0 auto",
        }}
      >
        {SLIDES.map((slide, i) => (
          <div key={slide.id}>
            <ScreenshotPreview
              slide={slide}
              cW={W}
              cH={H}
              exportRef={(el) => {
                exportRefs.current[i] = el;
              }}
            />
            <div
              style={{
                textAlign: "center",
                marginTop: 8,
                fontSize: 12,
                color: theme.textSecondary,
                fontWeight: 500,
              }}
            >
              {String(i + 1).padStart(2, "0")} — {slide.id}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
