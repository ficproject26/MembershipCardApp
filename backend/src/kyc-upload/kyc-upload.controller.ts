import { Controller, Get, Post, Body, Param, UploadedFiles, UseInterceptors, Header, NotFoundException } from '@nestjs/common';
import { FileFieldsInterceptor } from '@nestjs/platform-express';
import { KycUploadService } from './kyc-upload.service';

@Controller('kyc-upload')
export class KycUploadController {
  constructor(private readonly kycUploadService: KycUploadService) {}

  @Post('generate-link/:leadId')
  async generateLink(@Param('leadId') leadId: string) {
    const token = await this.kycUploadService.generateLink(leadId);
    return {
      token,
      url: `/kyc-upload/form/${token}`,
    };
  }

  @Get('documents/:leadId')
  async getDocuments(@Param('leadId') leadId: string) {
    return this.kycUploadService.getDocumentsByLead(leadId);
  }

  @Get('form/:token')
  @Header('Content-Type', 'text/html')
  async getForm(@Param('token') token: string) {
    const lead = await this.kycUploadService.getLeadByToken(token);
    
    const isSubmitted = lead.status === 'KYC_Pending' || lead.status === 'KYC_Verified' || lead.status === 'Approved' || lead.status === 'Dispatched';
    
    // Serve HTML content dynamically
    return this.getKycHtmlTemplate(token, lead.customerName || 'Valued Customer', lead.customerPhone || 'N/A', isSubmitted, lead.status);
  }

  @Post('submit/:token')
  @UseInterceptors(
    FileFieldsInterceptor([
      { name: 'aadhaar_front', maxCount: 1 },
      { name: 'aadhaar_back', maxCount: 1 },
      { name: 'pan_card', maxCount: 1 },
      { name: 'live_photo', maxCount: 1 },
      { name: 'passport_photo', maxCount: 1 },
    ]),
  )
  async submitKyc(
    @Param('token') token: string,
    @Body() body: { aadhaarNumber: string; panNumber: string },
    @UploadedFiles()
    files: {
      aadhaar_front?: Express.Multer.File[];
      aadhaar_back?: Express.Multer.File[];
      pan_card?: Express.Multer.File[];
      live_photo?: Express.Multer.File[];
      passport_photo?: Express.Multer.File[];
    },
  ) {
    return this.kycUploadService.submitKyc(token, body, files);
  }

  private getKycHtmlTemplate(token: string, customerName: string, customerPhone: string, isSubmitted: boolean, status: string): string {
    const statusText = status === 'KYC_Pending' ? 'Under Review' : (status === 'KYC_Verified' || status === 'Approved' || status === 'Dispatched' ? 'Verified' : status);
    const statusColor = status === 'KYC_Pending' ? '#FFC107' : '#4CAF50';

    return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>KYC Document Upload | FIC</title>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-dark: #0a1128;
      --card-bg: rgba(255, 255, 255, 0.05);
      --card-border: rgba(255, 255, 255, 0.1);
      --primary: #9C27B0;
      --secondary: #00F2FE;
      --text: #ffffff;
      --text-muted: #a0aec0;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      font-family: 'Outfit', sans-serif;
    }

    body {
      background: radial-gradient(circle at top right, #1d0f3a 0%, var(--bg-dark) 60%);
      color: var(--text);
      min-height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 20px;
      overflow-x: hidden;
    }

    .container {
      width: 100%;
      max-width: 650px;
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      backdrop-filter: blur(20px);
      -webkit-backdrop-filter: blur(20px);
      border-radius: 24px;
      padding: 40px;
      box-shadow: 0 20px 40px rgba(0,0,0,0.5);
      animation: fadeIn 0.8s ease-out;
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }

    .header {
      text-align: center;
      margin-bottom: 30px;
    }

    .logo-container {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 64px;
      height: 64px;
      background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
      border-radius: 16px;
      margin-bottom: 16px;
      box-shadow: 0 8px 20px rgba(156, 39, 176, 0.3);
    }

    .logo-container svg {
      width: 32px;
      height: 32px;
      fill: #fff;
    }

    h1 {
      font-size: 28px;
      font-weight: 700;
      margin-bottom: 8px;
      background: linear-gradient(to right, #fff 30%, #b8c6db 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }

    .subtitle {
      color: var(--text-muted);
      font-size: 15px;
    }

    .info-bar {
      background: rgba(255, 255, 255, 0.02);
      border: 1px solid rgba(255, 255, 255, 0.05);
      border-radius: 12px;
      padding: 16px;
      margin-bottom: 30px;
      display: flex;
      justify-content: space-around;
      font-size: 14px;
    }

    .info-item span {
      display: block;
      color: var(--text-muted);
      margin-bottom: 4px;
    }

    .info-item strong {
      color: #fff;
    }

    .form-group {
      margin-bottom: 24px;
    }

    label {
      display: block;
      font-size: 14px;
      font-weight: 600;
      margin-bottom: 8px;
      color: var(--text);
    }

    input[type="text"] {
      width: 100%;
      background: rgba(255, 255, 255, 0.05);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: 12px;
      padding: 14px 18px;
      color: #fff;
      font-size: 16px;
      outline: none;
      transition: all 0.3s;
    }

    input[type="text"]:focus {
      border-color: var(--secondary);
      box-shadow: 0 0 10px rgba(0, 242, 254, 0.2);
      background: rgba(255, 255, 255, 0.08);
    }

    /* Upload grid */
    .upload-grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 20px;
      margin-bottom: 30px;
    }

    @media (min-width: 480px) {
      .upload-grid {
        grid-template-columns: 1fr 1fr;
      }
      .span-2 {
        grid-column: span 2;
      }
    }

    .file-uploader {
      position: relative;
      border: 2px dashed rgba(255, 255, 255, 0.15);
      border-radius: 16px;
      padding: 24px 16px;
      text-align: center;
      background: rgba(255, 255, 255, 0.02);
      cursor: pointer;
      transition: all 0.3s;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 140px;
    }

    .file-uploader:hover {
      border-color: var(--primary);
      background: rgba(156, 39, 176, 0.05);
    }

    .file-uploader input[type="file"] {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      opacity: 0;
      cursor: pointer;
    }

    .upload-icon {
      font-size: 28px;
      margin-bottom: 10px;
      color: var(--text-muted);
    }

    .upload-label {
      font-size: 13px;
      font-weight: 600;
      color: #fff;
      margin-bottom: 4px;
    }

    .upload-desc {
      font-size: 11px;
      color: var(--text-muted);
    }

    .preview-container {
      display: none;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: #0a1128;
      border-radius: 14px;
      overflow: hidden;
    }

    .preview-img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .remove-btn {
      position: absolute;
      top: 8px;
      right: 8px;
      background: rgba(0, 0, 0, 0.7);
      border: none;
      color: #fff;
      width: 24px;
      height: 24px;
      border-radius: 50%;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 12px;
      z-index: 10;
    }

    .btn-submit {
      width: 100%;
      background: linear-gradient(135deg, var(--primary) 0%, #7b1fa2 100%);
      color: #fff;
      border: none;
      padding: 16px;
      border-radius: 12px;
      font-size: 16px;
      font-weight: 700;
      cursor: pointer;
      box-shadow: 0 8px 20px rgba(156, 39, 176, 0.3);
      transition: all 0.3s;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 10px;
    }

    .btn-submit:hover {
      transform: translateY(-2px);
      box-shadow: 0 12px 24px rgba(156, 39, 176, 0.5);
    }

    .btn-submit:active {
      transform: translateY(0);
    }

    .loader {
      display: none;
      width: 20px;
      height: 20px;
      border: 3px solid rgba(255,255,255,0.3);
      border-radius: 50%;
      border-top-color: #fff;
      animation: spin 1s ease-in-out infinite;
    }

    @keyframes spin {
      to { transform: rotate(360deg); }
    }

    /* Success / Info states */
    .success-container {
      text-align: center;
      padding: 20px 0;
    }

    .success-icon {
      font-size: 64px;
      margin-bottom: 20px;
      display: inline-block;
      animation: bounce 1s ease infinite alternate;
    }

    @keyframes bounce {
      from { transform: translateY(0); }
      to { transform: translateY(-10px); }
    }

    .status-badge {
      display: inline-block;
      padding: 6px 16px;
      border-radius: 20px;
      font-weight: 700;
      font-size: 14px;
      margin-top: 15px;
    }

    .error-msg {
      color: #ff3860;
      font-size: 13px;
      margin-top: 5px;
      display: none;
    }
  </style>
</head>
<body>

  <div class="container">
    ${isSubmitted ? `
      <div class="success-container">
        <div class="success-icon">📄</div>
        <h1>KYC Documents Submitted</h1>
        <p class="subtitle">Thank you, ${customerName}. Your verification details have been recorded.</p>
        
        <div class="status-badge" style="background-color: ${statusColor}22; color: ${statusColor}; border: 1px solid ${statusColor}44">
          Status: ${statusText}
        </div>
      </div>
    ` : `
      <div class="header">
        <div class="logo-container">
          <svg viewBox="0 0 24 24">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/>
          </svg>
        </div>
        <h1>KYC Document Upload</h1>
        <p class="subtitle">Secure portal to complete your identity verification</p>
      </div>

      <div class="info-bar">
        <div class="info-item">
          <span>Applicant</span>
          <strong>${customerName}</strong>
        </div>
        <div class="info-item">
          <span>Contact</span>
          <strong>${customerPhone}</strong>
        </div>
      </div>

      <form id="kycForm">
        <div class="form-group">
          <label for="aadhaarNumber">Aadhaar Number (12 digits)</label>
          <input type="text" id="aadhaarNumber" name="aadhaarNumber" placeholder="e.g. 1234 5678 9012" required pattern="\\d{12}">
          <div class="error-msg" id="aadhaarError">Please enter a valid 12-digit Aadhaar number.</div>
        </div>

        <div class="form-group">
          <label for="panNumber">PAN Card Number</label>
          <input type="text" id="panNumber" name="panNumber" placeholder="e.g. ABCDE1234F" style="text-transform: uppercase;" required pattern="[A-Z]{5}[0-9]{4}[A-Z]{1}">
          <div class="error-msg" id="panError">Please enter a valid PAN number format (e.g. ABCDE1234F).</div>
        </div>

        <label style="margin-bottom: 12px;">Required Uploads</label>
        
        <div class="upload-grid">
          <div class="file-uploader">
            <span class="upload-icon">🪪</span>
            <span class="upload-label">Aadhaar Front</span>
            <span class="upload-desc">JPG, PNG (Max 5MB)</span>
            <input type="file" name="aadhaar_front" accept="image/*" required>
            <div class="preview-container">
              <button type="button" class="remove-btn">&times;</button>
              <img class="preview-img" src="" alt="Aadhaar Front">
            </div>
          </div>

          <div class="file-uploader">
            <span class="upload-icon">🪪</span>
            <span class="upload-label">Aadhaar Back</span>
            <span class="upload-desc">JPG, PNG (Max 5MB)</span>
            <input type="file" name="aadhaar_back" accept="image/*" required>
            <div class="preview-container">
              <button type="button" class="remove-btn">&times;</button>
              <img class="preview-img" src="" alt="Aadhaar Back">
            </div>
          </div>

          <div class="file-uploader">
            <span class="upload-icon">💳</span>
            <span class="upload-label">PAN Card Photo</span>
            <span class="upload-desc">JPG, PNG (Max 5MB)</span>
            <input type="file" name="pan_card" accept="image/*" required>
            <div class="preview-container">
              <button type="button" class="remove-btn">&times;</button>
              <img class="preview-img" src="" alt="PAN Card">
            </div>
          </div>

          <div class="file-uploader">
            <span class="upload-icon">📸</span>
            <span class="upload-label">Live Photo / Selfie</span>
            <span class="upload-desc">Take a clear picture</span>
            <input type="file" name="live_photo" accept="image/*" capture="user" required>
            <div class="preview-container">
              <button type="button" class="remove-btn">&times;</button>
              <img class="preview-img" src="" alt="Live Photo">
            </div>
          </div>

          <div class="file-uploader span-2">
            <span class="upload-icon">👤</span>
            <span class="upload-label">Passport Size Photo</span>
            <span class="upload-desc">Clear professional photo</span>
            <input type="file" name="passport_photo" accept="image/*" required>
            <div class="preview-container">
              <button type="button" class="remove-btn">&times;</button>
              <img class="preview-img" src="" alt="Passport Photo">
            </div>
          </div>
        </div>

        <button type="submit" class="btn-submit" id="submitBtn">
          <span>Submit Verification</span>
          <div class="loader" id="submitLoader"></div>
        </button>
      </form>
    `}
  </div>

  <script>
    // File inputs preview handling
    document.querySelectorAll('.file-uploader input[type="file"]').forEach(input => {
      input.addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file) {
          if (file.size > 5 * 1024 * 1024) {
            alert('File size exceeds 5MB limit.');
            e.target.value = '';
            return;
          }
          const reader = new FileReader();
          const uploader = e.target.closest('.file-uploader');
          const previewContainer = uploader.querySelector('.preview-container');
          const previewImg = uploader.querySelector('.preview-img');
          
          reader.onload = function(event) {
            previewImg.src = event.target.result;
            previewContainer.style.display = 'block';
          };
          reader.readAsDataURL(file);
        }
      });
    });

    // Remove buttons handling
    document.querySelectorAll('.remove-btn').forEach(btn => {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        const previewContainer = e.target.closest('.preview-container');
        const uploader = e.target.closest('.file-uploader');
        const input = uploader.querySelector('input[type="file"]');
        
        input.value = '';
        previewContainer.style.display = 'none';
      });
    });

    // Formatting Aadhaar
    const aadhaarInput = document.getElementById('aadhaarNumber');
    if (aadhaarInput) {
      aadhaarInput.addEventListener('input', function(e) {
        // Strip non-digits
        let val = e.target.value.replace(/\\D/g, '');
        if (val.length > 12) val = val.substring(0, 12);
        e.target.value = val;
      });
    }

    // Formatting PAN
    const panInput = document.getElementById('panNumber');
    if (panInput) {
      panInput.addEventListener('input', function(e) {
        e.target.value = e.target.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
      });
    }

    // Submit handler
    const form = document.getElementById('kycForm');
    if (form) {
      form.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        // Front-end validations
        const aadhaarNum = document.getElementById('aadhaarNumber').value;
        const panNum = document.getElementById('panNumber').value;
        
        const aadhaarError = document.getElementById('aadhaarError');
        const panError = document.getElementById('panError');
        
        let isValid = true;
        
        if (aadhaarNum.length !== 12) {
          aadhaarError.style.display = 'block';
          isValid = false;
        } else {
          aadhaarError.style.display = 'none';
        }
        
        const panRegex = /[A-Z]{5}[0-9]{4}[A-Z]{1}/;
        if (!panRegex.test(panNum)) {
          panError.style.display = 'block';
          isValid = false;
        } else {
          panError.style.display = 'none';
        }
        
        if (!isValid) return;
        
        const submitBtn = document.getElementById('submitBtn');
        const loader = document.getElementById('submitLoader');
        
        submitBtn.disabled = true;
        loader.style.display = 'block';
        submitBtn.querySelector('span').innerText = 'Uploading documents...';

        try {
          const formData = new FormData(form);
          const response = await fetch('/kyc-upload/submit/${token}', {
            method: 'POST',
            body: formData
          });
          
          const result = await response.json();
          if (response.ok) {
            window.location.reload();
          } else {
            alert(result.message || 'Submission failed. Please check files and try again.');
            resetButton();
          }
        } catch (err) {
          console.error(err);
          alert('Network error occurred. Please try again.');
          resetButton();
        }
      });
    }

    function resetButton() {
      const submitBtn = document.getElementById('submitBtn');
      const loader = document.getElementById('submitLoader');
      submitBtn.disabled = false;
      loader.style.display = 'none';
      submitBtn.querySelector('span').innerText = 'Submit Verification';
    }
  </script>
</body>
</html>
    `;
  }
}
