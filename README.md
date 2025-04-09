# Landscapes 2.5

## Overview

**Landscapes** is a MATLAB script that loads, analyzes, and visualizes integrated X-ray diffraction patterns (generated with `fit2D`) as a function of a chosen experimental variable (e.g. temperature, phi, zeta, etc.). It highlights patterns corresponding to significant values of the chosen variable, as identified, for example, through calorimetry experiments.

Originally designed for temperature-dependent diffraction, the script has been extended to support alternative variables.

## Features

- Visualization of SAXS and WAXS data as a function of a variable
- Support for various colormaps and customizable figure options
- Optional interpolation of missing data (e.g. due to detector grids)
- DSC overlay and highlighting of onset/peak/endset points

## File Requirements

For each image to be generated, the following files must be present in the working folder:

- `.chi` files: intensity patterns from `fit2D`
- `OPE.txt`: a text file with at least two values per peak (onset, peak, endset). If only two are given, they are assumed to be onset and endset.
- If your pattern includes "holes" (e.g., from a Pilatus detector grid), make sure the intensity in these regions is **exactly zero** (use a threshold mask). This allows the script to either interpolate or ignore these areas.

## Required Parameters

You must know the wavelength used in your experiment and define various plot customization parameters in the script header.

## To-Do

- [ ] Automate copying of the `inpaint_nans` script for interpolation of missing data
- [ ] Allow interactive selection of colormaps for DSC and interpolated areas
- [ ] Normalize data to a chosen interplanar distance (d)
- [ ] Automatically detect whether OPE.txt contains 2 or 3 points per peak
- [ ] Extend line 972 procedure to other thermal paths

## Getting Started

1. Clone or download this repository.
2. Place all required data files in the working directory.
3. Open `Landscapes.m` in MATLAB.
4. Adjust parameters in the **header section** (`%% Settaggio parametri`) according to your experimental setup:
   - Select the variable (`Temperature`, `Zeta`, `Phi`, etc.)
   - Set wavelength (`lambda`)
   - Adjust output preferences (`flagfigure`, colormaps, etc.)
5. Run the script.

## Output

The script generates up to 9 different figures, corresponding to different representations of SAXS and WAXS data (complete datasets, heating/cooling subsets, grayscale versions, contour plots, etc.).

## License

Feel free to reuse, adapt, and share — just acknowledge the source.

---

### Example Header Configuration (from the script)

```matlab
Variable = 'Temperature';
xlabelVariable = 'Temperature (°C)';
lambda = 1.2; % Wavelength
flagfigure = [1,1,1,1,1,1,1,1,1]; % Enable all output figures
createcolorbar = false;
titolofigura = 'Noccioli Organogel ';
