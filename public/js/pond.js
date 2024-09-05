// public/js/pond3.js
document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('file-upload-form');
  
  if (form) {
    form.addEventListener('submit', (event) => {
      event.preventDefault(); // Preventing traditional form submission (we also removed the upload button from upload.erb)
    });
  }

  const inputElement = document.querySelector('input[type="file"]');
  
  if (inputElement) {
    const pond = FilePond.create(inputElement, {
      allowMultiple: false,
      maxFiles: 1,
      server: {
        process: {
          url: '/upload',
          method: 'POST',
          headers: {
            // Add CSRF token???
          },
          ondata: (formData) => {
            formData.append('expiration', document.querySelector('#expiration').value);
            return formData;
          },
          onload: (response) => {
            const jsonResponse = JSON.parse(response); // Parse the JSON response
            const link = jsonResponse.link;

            // Show success message with the link dynamically
            const successMessage = `
              <div class="alert alert-success">
                File uploaded successfully! Your link: 
                <a href="${link}" target="_blank">${link}</a>
              </div>
            `;

            // Inject the message into the form or somewhere on the page
            document.querySelector('article').insertAdjacentHTML('beforeend', successMessage);

            console.log('File uploaded successfully:', link);
          },
          onerror: (response) => {
            console.error('File upload error:', response);
          }
        }
      }
    });
  }
});
