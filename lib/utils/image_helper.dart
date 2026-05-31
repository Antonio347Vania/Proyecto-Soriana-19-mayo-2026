import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageHelper {
  // Decodificar imagen base64 de forma segura
  static Uint8List? decodeBase64Image(String base64String) {
    try {
      if (base64String.isEmpty) return null;
      
      // Limpiar la cadena base64
      String cleanBase64 = base64String;
      
      // Si tiene prefijo data:image, extraer solo la parte base64
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }
      
      // Remover espacios en blanco y caracteres inválidos
      cleanBase64 = cleanBase64.trim();
      cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s'), '');
      
      // Intentar decodificar
      return base64Decode(cleanBase64);
    } catch (e) {
      print('Error decodificando imagen: $e');
      return null;
    }
  }
  
  // Obtener widget de imagen de forma segura
  static Widget getImageWidget(String base64String, double size) {
    final imageBytes = decodeBase64Image(base64String);
    
    if (imageBytes != null && imageBytes.isNotEmpty) {
      try {
        return ClipOval(
          child: Image.memory(
            imageBytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(size);
            },
          ),
        );
      } catch (e) {
        return _buildPlaceholder(size);
      }
    } else {
      return _buildPlaceholder(size);
    }
  }
  
  static Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: Icon(Icons.person, size: size * 0.6, color: Colors.grey),
    );
  }
}