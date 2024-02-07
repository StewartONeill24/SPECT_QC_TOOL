# SPECT Image Quality Control Tool

## Overview
The SPECT Image Quality Control Tool is a MATLAB-based application developed to ensure the quality of SPECT (Single Photon Emission Computed Tomography) imaging by analyzing DICOM images. This tool facilitates the automated evaluation of SPECT images through various quality metrics, including Full Width at Half Maximum (FWHM), to assist in the clinical and research settings.

## Key Features
- **DICOM Image Analysis**: Supports analysis of DICOM images, extracting necessary image metadata for quality control.
- **Automated Quality Metrics Calculation**: Calculates critical quality metrics such as FWHM for axial, coronal, and sagittal orientations.
- **Interactive ROI Selection**: Enables users to interactively select regions of interest within the image for focused analysis.
- **Quality Reporting**: Generates comprehensive reports summarizing the QC analysis, including various quality metrics for easy interpretation.

## Installation
Ensure MATLAB (R2019b or newer) is installed on your system. This tool does not require additional MATLAB toolboxes for its basic functionalities.

### Steps
1. Download or clone the repository to your local machine:
   ```sh
   git clone https://github.com/StewartONeill24/SPECT_QC_TOOL.git
   ```
2. Open MATLAB and navigate to the cloned repository's directory.
3. Add the project folder to your MATLAB path to ensure access to all functions:
   ```matlab
   addpath(genpath('SPECT_QC_TOOL'));
   ```

## Usage
To start the SPECT QC analysis:
1. Open the `QC_Tool.m` script in MATLAB.
2. Run the script by pressing the Run button or typing `QC_Tool` in the Command Window.

Follow the on-screen instructions for interactive ROI selection and analysis. The tool will process the selected DICOM images, calculate quality metrics, and generate a report summarizing the findings.

## Contributing
Contributions to the SPECT QC Tool are welcome. To contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -am 'Add some YourFeature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a pull request.

Please ensure your code adheres to best practices and consider adding comments for clarity.

## Support
For support, please open an issue on the GitHub repository. For direct assistance, contact the project maintainers.

## Acknowledgments
This project was made possible by the contributions of numerous individuals in the medical imaging community. We extend our gratitude to all those who have offered insights, feedback, and support.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for more details.

