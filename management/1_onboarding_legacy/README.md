# Onboarding & Registration Documentation

Technical specifications and flowcharts for the user onboarding and pre-registration process.

## Diagrams
- [onboarding_legacy.mmd](./onboarding_legacy.mmd): Professional flowchart mapping the end-to-end registration lifecycle. Includes data entry points, system validations (RENAPO, CP), and administrative review steps.

## Technical Flow Overview
1. **Credentials Setup**: Profile type selection (Patient/Doctor) and secure account creation.
2. **Identity Verification**: Multi-channel OTP (One-Time Password) validation.
3. **Document Ingestion**: Digital capture of Identification (Official ID) and Proof of Residence.
4. **General Information Capture**: 
    - **Personal Data**: Automated CURP validation and identity autocompletion.
    - **Location Data**: Postal Code georeferencing and neighborhood selection.
5. **Administrative Review**: 48-hour business window for document verification and profile activation.

## Implementation Notes
The [onboarding_legacy.mmd](./onboarding_legacy.mmd) diagram uses standard flowchart symbols:
- **Parallelograms**: Manual data entry fields.
- **Diamonds**: Logical decision points.
- **Rectangles**: Automated system processes.
