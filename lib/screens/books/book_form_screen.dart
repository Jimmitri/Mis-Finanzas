  import 'package:file_picker/file_picker.dart';
  import 'package:flutter/material.dart';

  import '../../database/book_repository.dart';
  import '../../models/book.dart';
  import '../../utils/constants.dart';
  import '../../utils/session.dart';
  import '../../widgets/custom_button.dart';
  import '../../widgets/custom_textfield.dart';

  class BookFormScreen extends StatefulWidget {

    final Book? book;

    const BookFormScreen({
      super.key,
      this.book,
    });

    @override
    State<BookFormScreen> createState() => _BookFormScreenState();
  }

  class _BookFormScreenState extends State<BookFormScreen> {
    final _formKey = GlobalKey<FormState>();

    final BookRepository _repository = BookRepository();

    bool get isEditing => widget.book != null;

    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final categoryController = TextEditingController();
    final yearController = TextEditingController();
    final imageController = TextEditingController();
    final descriptionController = TextEditingController();

    String selectedStatus = BookStatus.unread;

    String? pdfPath;

    Future<void> selectPdf() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
       setState(() {
          pdfPath = result.files.single.path;
          });
        }
      }
      @override
      void initState() {
        super.initState();

        if (isEditing) {

          titleController.text = widget.book!.title;
          authorController.text = widget.book!.author;
          categoryController.text = widget.book!.category;
          yearController.text = widget.book!.year.toString();
          imageController.text = widget.book!.imageUrl;
          descriptionController.text = widget.book!.description;

          pdfPath = widget.book!.pdfPath;

          selectedStatus = widget.book!.status;
        }
      }
      @override
        Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing
                ? "Editar Libro"
                : "Agregar Libro",
          ),
        ),
        body: SafeArea(
        child: Form(
        key: _formKey,
        child: ListView(
        padding: const EdgeInsets.all(20),
        children: [

      const Text(
        "Información del libro",
        style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 8),

      const Text(
        "Completa todos los campos",
        style: TextStyle(
        color: Colors.grey,
        ),
      ),

      const SizedBox(height: 25),
      CustomTextField(
        controller: titleController,
        label: "Título",
        icon: Icons.menu_book,
        validator: (value) {
        if (value == null || value.trim().isEmpty) {
        return "Ingrese el título";
        }
        return null;
        },
      ),

      const SizedBox(height: 18),

        CustomTextField(
          controller: authorController,
          label: "Autor",
          icon: Icons.person,
          validator: (value) {
          if (value == null || value.trim().isEmpty) {
          return "Ingrese el autor";
          }
          return null;
          },
        ),

      const SizedBox(height: 18),

        CustomTextField(
          controller: categoryController,
          label: "Categoría",
          icon: Icons.category,
          validator: (value) {
          if (value == null || value.trim().isEmpty) {
          return "Ingrese la categoría";
          }
          return null;
          },
        ),

      const SizedBox(height: 18),

        CustomTextField(
          controller: yearController,
          label: "Año",
          icon: Icons.calendar_month,
          keyboardType: TextInputType.number,
          validator: (value) {
          if (value == null || value.trim().isEmpty) {
          return "Ingrese el año";
          }

          if (int.tryParse(value) == null) {
          return "Ingrese un año válido";
          }

          return null;
          },
        ),

        const SizedBox(height: 18),

        CustomTextField(
          controller: imageController,
          label: "URL de la portada",
          icon: Icons.image,
          validator: (value) {
          if (value == null || value.trim().isEmpty) {
          return "Ingrese la URL";
          }
          return null;
          },
        ),

        const SizedBox(height: 20),

          Container(
            height: 180,
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
            ),
              child: Center(
              child: imageController.text.isEmpty
              ? const Icon(
              Icons.image,
              size: 70,
              )
              : Image.network(
              imageController.text,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
              return const Icon(
              Icons.broken_image,
              size: 70,
              );
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Archivo PDF",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                pdfPath == null
                    ? "Ningún archivo seleccionado"
                    : pdfPath!.split('/').last,
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: 170,
                child: ElevatedButton.icon(
                  onPressed: selectPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Seleccionar PDF"),
                ),
              ),

            ],
          ),

        const SizedBox(height: 20),

          CustomTextField(
            controller: descriptionController,
            label: "Descripción",
            icon: Icons.description,
            maxLines: 4,
          ),

        const SizedBox(height: 20),

          DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
              labelText: "Estado",
              border: OutlineInputBorder(),
              ),
              items: const [
            DropdownMenuItem(
              value: BookStatus.unread,
              child: Text("No leído"),
            ),
            DropdownMenuItem(
              value: BookStatus.reading,
              child: Text("Leyendo"),
            ),
            DropdownMenuItem(
              value: BookStatus.finished,
              child: Text("Terminado"),
              ),
              ],
              onChanged: (value) {
              setState(() {
              selectedStatus = value!;
              });
            },
          ),

        const SizedBox(height: 30),
          CustomButton(
            text: isEditing
                ? "Actualizar Libro"
                : "Guardar Libro",
            icon: Icons.save,
            onPressed: saveBook,
          ),

        ],
        ),
        ),
        ),
        );
      }

    Future<void> saveBook() async {

      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (pdfPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Seleccione un archivo PDF"),
          ),
        );
        return;
      }

      final int? year = int.tryParse(yearController.text);

      if (year == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ingrese un año válido"),
          ),
        );
        return;
      }

      if (Session.userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Debe iniciar sesión nuevamente"),
          ),
        );
        return;
      }

      final book = Book(
        id: isEditing ? widget.book!.id : null,
        userId: Session.userId!,
        title: titleController.text.trim(),
        author: authorController.text.trim(),
        category: categoryController.text.trim(),
        year: year,
        description: descriptionController.text.trim(),
        imageUrl: imageController.text.trim(),
        pdfPath: pdfPath!,
        status: selectedStatus,

        favorite: isEditing
            ? widget.book!.favorite
            : false,
      );

      try {

        if (isEditing) {

          await _repository.updateBook(book);

        } else {

          await _repository.addBook(book);

        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? "Libro actualizado correctamente"
                  : "Libro guardado correctamente",
            ),
          ),
        );

        Navigator.pop(context, true);

      } catch (e) {

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
          ),
        );

      }
    }

    @override
    void dispose() {
      titleController.dispose();
      authorController.dispose();
      categoryController.dispose();
      yearController.dispose();
      imageController.dispose();
      descriptionController.dispose();
      super.dispose();
    }
  }