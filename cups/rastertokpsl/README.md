# rastertokpsl — Kyocera KPSL CUPS filter (open-source re-implementation)

Vendored from [sv99/rastertokpsl-re](https://github.com/sv99/rastertokpsl-re)
(commit 786dff5, files verified byte-identical to the upstream `src/` tree),
licensed under the Apache License 2.0 (see `LICENSE`).

## Why this is vendored

Kyocera GDI (KPSL) printers — FS-1040/1041, FS-1060DN/1061DN,
FS-1020/1025/1120/1125MFP — are host-based printers that only understand
Kyocera's proprietary KPSL raster format. Their PPDs reference the
`rastertokpsl` CUPS filter:

```
*cupsFilter: "application/vnd.cups-raster 0 /usr/lib/cups/filter/rastertokpsl"
```

The official filter binary is proprietary Kyocera software and is not
available in the Alpine repositories, so the add-on builds this
Apache-2.0 open-source re-implementation into the image at
`/usr/lib/cups/filter/rastertokpsl`.

## Files

- `main.c`, `rastertokpsl.c`, `rastertokpsl.h`, `halfton.c`, `halfton.h` —
  the filter itself (CUPS raster → KPSL)
- `libjbig/` — JBIG1 arithmetic coder used for KPSL compression
  (JBIG-KIT, only `jbig.c`/`jbig_ar.c` are compiled)
- `unicode/` — UTF-8 <-> UTF-16 conversion for job/user/title strings

## Build (as done in the Dockerfile)

```
gcc -O2 -o /usr/lib/cups/filter/rastertokpsl \
    main.c rastertokpsl.c halfton.c \
    libjbig/jbig.c libjbig/jbig_ar.c \
    unicode/ConvertUTF.c \
    -lcups -lm
```

Requires `cups-dev` for the CUPS raster API headers. The filter is a
standard CUPS raster-input filter: `rastertokpsl job-id user title copies
options [raster-file]`.

## The PPDs

The matching Kyocera GDI PPDs live in
`rootfs/usr/share/cups/model/kyocera/`; they are the official Kyocera PPDs
(driver v1.1203) redistributed unmodified as permitted by their embedded
copyright notice.
