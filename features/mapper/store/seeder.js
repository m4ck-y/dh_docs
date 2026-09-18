// mongosh: pegar y ejecutar. Idempotente.
// DB: dh_bindings · Colección: bindings

use('dh_bindings');

// 1) Colección
if (!db.getCollectionNames().includes('bindings')) {
  db.createCollection('bindings');
}

// 2) Índices
db.bindings.createIndex(
  { 'source.form': 1, 'source.question': 1 },
  { unique: true, name: 'uq_form_question' }
);
db.bindings.createIndex(
  { 'source.form': 1, 'enabled': 1, 'target.operations': 1 },
  { name: 'ix_form_enabled_ops' }
);

// 3) Seed (upsert idempotente por form+question)
db.bindings.bulkWrite([
  {
    updateOne: {
      filter: {
        'source.form': 'datos_personales',
        'source.question': 'datos.fecha_nacimiento'
      },
      update: {
        $set: {
          name: 'Fecha de nacimiento',
          target: { engine: 'POSTGRES', schema: 'people', table: 'birth',
                    property: 'birth_date', operations: ['READ', 'WRITE'] },
          enabled: true,
          updated_at: new Date()
        },
        $setOnInsert: {
          uuid: UUID(),
          created_at: new Date(),
          created_by: null,
          updated_by: null
        }
      },
      upsert: true
    }
  }
]);

print('Seed dh_bindings.bindings OK');
