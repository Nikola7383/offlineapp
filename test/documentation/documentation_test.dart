import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/documentation/doc_validator.dart';

void main() {
  late DocValidator validator;

  setUp(() {
    validator = DocValidator(logger: LoggerService());
  });

  group('Documentation Tests', () {
    test('Should validate API documentation', () async {
      final apiDocs = await validator.validateApiDocumentation();

      expect(apiDocs.coverage, equals(1.0)); // 100% pokrivenost
      expect(apiDocs.examples, areComplete);
      expect(apiDocs.parameters, areDocumented);

      // Provera specifičnih API endpointa
      for (final endpoint in apiDocs.endpoints) {
        expect(endpoint.description, isNotEmpty);
        expect(endpoint.parameters, areDocumented);
        expect(endpoint.responses, areDocumented);
      }
    });

    test('Should verify code documentation', () async {
      final codeDocs = await validator.verifyCodeDocumentation();

      expect(codeDocs.publicApiCoverage, greaterThan(0.9)); // Min 90%
      expect(codeDocs.complexMethodsCoverage, equals(1.0));
      expect(codeDocs.readmeFiles, exist);

      // Provera dokumentacije kritičnih komponenti
      for (final component in codeDocs.criticalComponents) {
        expect(component.documentation, isComplete);
        expect(component.examples, areProvided);
      }
    });

    test('Should validate user documentation', () async {
      final userDocs = await validator.validateUserDocumentation();

      expect(userDocs.gettingStarted, exists);
      expect(userDocs.troubleshooting, isComprehensive);
      expect(userDocs.features, areExplained);

      // Provera specifičnih sekcija
      for (final section in userDocs.sections) {
        expect(section.content, isNotEmpty);
        expect(section.images, areRelevant);
        expect(section.steps, areClear);
      }
    });
  });
}
