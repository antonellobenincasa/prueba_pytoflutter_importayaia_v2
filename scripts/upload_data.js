const admin = require('firebase-admin');
const fs = require('fs');

// --- 1. VERIFICACIÓN DE LLAVE ---
if (!fs.existsSync('./serviceAccount.json')) {
    console.error("❌ ERROR FATAL: No encuentro 'serviceAccount.json'.");
    process.exit(1);
}

const serviceAccount = require('./serviceAccount.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// --- 2. FUNCIÓN DE CARGA INTELIGENTE (CON LIMPIEZA DE DATOS) ---
async function uploadCollection(collectionName, fileName) {
    if (!fs.existsSync(fileName)) {
        console.warn(`⚠️  Archivo '${fileName}' no encontrado. Saltando colección '${collectionName}'...`);
        return;
    }

    try {
        const rawData = fs.readFileSync(fileName, 'utf8');
        let data = JSON.parse(rawData);

        const TOTAL = data.length;
        const BATCH_SIZE = 400;
        let batches_count = 0;
        let records_count = 0;

        console.log(`\n⏳ Iniciando carga de '${collectionName}' (${TOTAL} registros)...`);

        for (let i = 0; i < TOTAL; i += BATCH_SIZE) {
            const chunk = data.slice(i, i + BATCH_SIZE);
            const batch = db.batch();

            chunk.forEach((item) => {
                // --- PASO DE LIMPIEZA (SANITIZACIÓN) ---
                const cleanItem = {};
                Object.keys(item).forEach(key => {
                    // Solo guardamos si la llave NO está vacía y NO es espacios en blanco
                    if (key && key.trim() !== "") {
                        cleanItem[key] = item[key];
                    }
                });

                // Si después de limpiar el objeto quedó vacío, no lo subimos
                if (Object.keys(cleanItem).length > 0) {
                    const docRef = db.collection(collectionName).doc();
                    batch.set(docRef, cleanItem);
                }
            });

            await batch.commit();
            records_count += chunk.length;
            batches_count++;
            process.stdout.write(`   📦 Lote ${batches_count} subido (${records_count}/${TOTAL})...\r`);
        }

        console.log(`\n✅ ÉXITO: '${collectionName}' completado.`);

    } catch (e) {
        if (e instanceof SyntaxError) {
            console.error(`\n❌ ERROR DE FORMATO EN '${fileName}': No es un JSON válido.`);
        } else {
            console.error(`\n❌ ERROR SUBIENDO '${collectionName}':`, e.message);
        }
    }
}

// --- FUNCIÓN ESPECIAL PARA CONFIGURACIÓN ---
async function uploadConfig(fileName) {
    if (!fs.existsSync(fileName)) return;
    try {
        const rawData = fs.readFileSync(fileName, 'utf8');
        const data = JSON.parse(rawData);
        const configObject = {};

        data.forEach(item => {
            let key = item.clave || item.constante;
            if (!key || key.trim() === "") return;

            let val = item.valor;
            if (val !== null && val !== "" && !isNaN(val)) {
                val = Number(val);
            }
            configObject[key] = val;
        });

        await db.collection('system_config').doc('global_vars').set(configObject, { merge: true });
        console.log(`\n✅ Configuración Global actualizada desde '${fileName}'.`);
    } catch (e) {
        console.error(`❌ Error procesando configuración '${fileName}':`, e.message);
    }
}

// --- 3. EJECUCIÓN PRINCIPAL ---
async function main() {
    console.log("🚀 --- INICIANDO CARGA MASIVA DEL SISTEMA ---");

    // === A. MAESTROS BÁSICOS ===
    await uploadCollection('ports', 'puertos.json');
    await uploadCollection('airports', 'aeropuertos.json');
    await uploadCollection('providers', 'proveedores.json');
    await uploadCollection('unidades_medida', 'unidades.json');

    // ** NUEVO **: Países de Origen -> Colección 'countries'
    await uploadCollection('countries', 'paises.json');

    // ** NUEVO **: Cobertura de Ciudades
    await uploadCollection('cobertura_ciudades', 'ciudades_cobertura_ecuador.json');

    // === B. TARIFARIOS INTERNACIONALES (FCL, LCL, AEREO) ===
    await uploadCollection('tarifario_fcl', 'tarifario_FCL_07012026.json');
    await uploadCollection('tarifario_lcl', 'tarifario_LCL_07012026.json');
    await uploadCollection('tarifario_aereo', 'tarifario_AEREO_07012026.json');

    // === C. LOGÍSTICA TERRESTRE Y LEGAL ===
    await uploadCollection('tarifario_transporte_interno', 'tarifario_transporte_interno.json');
    await uploadCollection('seguridad_candado_custodia', 'seguridad_candado_custodia.json');
    await uploadCollection('condiciones_legales', 'condiciones_legales_terrestre.json');
    await uploadCollection('incoterms', 'incoterms.json');

    // === D. INTELIGENCIA Y ADUANA ===
    await uploadCollection('hs_codes', 'partidas_estrategicas_unificadas.json');
    await uploadCollection('hs_codes_comunes', 'hs_codes_comunes.json');
    await uploadCollection('ad_valorem_referencial', 'ad_valorem_referencial.json');
    await uploadCollection('impuesto_ice', 'impuesto_ice.json');

    // Respaldo de locales destino (si aún lo usas)
    await uploadCollection('locales_destino_fcl_navieras', 'locales_destino_fcl_navieras.json');

    // === E. CONFIGURACIÓN ===
    await uploadConfig('configuracion_sistema.json');
    await uploadConfig('constantes_sistema.json');

    console.log("\n🏁 --- PROCESO FINALIZADO ---");
}

main();