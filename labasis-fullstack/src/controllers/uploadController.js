// src/controllers/uploadController.js

const fs = require('fs');
const path = require('path');

class UploadController {
  // Subir imagen única
  uploadImage(req, res) {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: 'No se proporcionó ninguna imagen'
        });
      }

      const imageUrl = `/uploads/images/${req.file.filename}`;

      res.status(201).json({
        success: true,
        message: 'Imagen subida exitosamente',
        data: {
          filename: req.file.filename,
          originalName: req.file.originalname,
          size: req.file.size,
          url: imageUrl,
          path: req.file.path
        }
      });
    } catch (error) {
      console.error('Error subiendo imagen:', error);
      res.status(500).json({
        success: false,
        message: 'Error al subir la imagen'
      });
    }
  }

  // Subir múltiples imágenes
  uploadMultipleImages(req, res) {
    try {
      if (!req.files || req.files.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'No se proporcionaron imágenes'
        });
      }

      const images = req.files.map(file => ({
        filename: file.filename,
        originalName: file.originalname,
        size: file.size,
        url: `/uploads/images/${file.filename}`,
        path: file.path
      }));

      res.status(201).json({
        success: true,
        message: `${req.files.length} imágenes subidas exitosamente`,
        data: {
          count: req.files.length,
          images: images
        }
      });
    } catch (error) {
      console.error('Error subiendo imágenes:', error);
      res.status(500).json({
        success: false,
        message: 'Error al subir las imágenes'
      });
    }
  }

  // Subir archivo (PDF, doc, etc.)
  uploadFile(req, res) {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: 'No se proporcionó ningún archivo'
        });
      }

      const fileUrl = `/uploads/files/${req.file.filename}`;

      res.status(201).json({
        success: true,
        message: 'Archivo subido exitosamente',
        data: {
          filename: req.file.filename,
          originalName: req.file.originalname,
          size: req.file.size,
          mimetype: req.file.mimetype,
          url: fileUrl,
          path: req.file.path
        }
      });
    } catch (error) {
      console.error('Error subiendo archivo:', error);
      res.status(500).json({
        success: false,
        message: 'Error al subir el archivo'
      });
    }
  }

  // Listar archivos de una carpeta
  listFiles(req, res) {
    try {
      const { type } = req.params; // 'images' o 'files'
      
      if (!['images', 'files'].includes(type)) {
        return res.status(400).json({
          success: false,
          message: 'Tipo inválido. Usa "images" o "files"'
        });
      }

      const folderPath = path.join(__dirname, '../../uploads', type);

      if (!fs.existsSync(folderPath)) {
        return res.json({
          success: true,
          data: []
        });
      }

      const files = fs.readdirSync(folderPath).map(filename => {
        const filePath = path.join(folderPath, filename);
        const stats = fs.statSync(filePath);
        
        return {
          filename,
          size: stats.size,
          created: stats.birthtime,
          url: `/uploads/${type}/${filename}`
        };
      });

      res.json({
        success: true,
        data: files
      });
    } catch (error) {
      console.error('Error listando archivos:', error);
      res.status(500).json({
        success: false,
        message: 'Error al listar archivos'
      });
    }
  }

  // Eliminar archivo
  deleteFile(req, res) {
    try {
      const { type, filename } = req.params;

      if (!['images', 'files'].includes(type)) {
        return res.status(400).json({
          success: false,
          message: 'Tipo inválido. Usa "images" o "files"'
        });
      }

      const filePath = path.join(__dirname, '../../uploads', type, filename);

      if (!fs.existsSync(filePath)) {
        return res.status(404).json({
          success: false,
          message: 'Archivo no encontrado'
        });
      }

      fs.unlinkSync(filePath);

      res.json({
        success: true,
        message: 'Archivo eliminado exitosamente'
      });
    } catch (error) {
      console.error('Error eliminando archivo:', error);
      res.status(500).json({
        success: false,
        message: 'Error al eliminar el archivo'
      });
    }
  }
}

module.exports = new UploadController();