import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Outlook'),
          backgroundColor: Colors.purple,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: EmailForm(),
        ),
      ),
    );
  }
}

class EmailForm extends StatefulWidget {
  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>();

  final String _email = "malarvili@elgi.com";
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            'Email ID: $_email',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextFormField(
            controller: _subjectController,
            decoration: InputDecoration(labelText: 'Subject'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a subject';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _bodyController,
            decoration: InputDecoration(labelText: 'Body'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a body';
              }
              return null;
            },
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.purple)),
            onPressed: () => _sendEmail(),
            child: Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _sendEmail() async {
    if (_formKey.currentState!.validate()) {
      final Email email = Email(
        recipients: [_email],
        subject: _subjectController.text,
        body: _bodyController.text,
      );

      try {
        await FlutterEmailSender.send(email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email sent successfully')),
        );
      } catch (error, stackTrace) {
        print('Error sending email: $error');
        print('Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email')),
        );
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
