# ⚠️ PROCESSO DE DEPLOY DO PWA - NUNCA MAIS ESQUECER

## PROBLEMA RECORRENTE
O Firebase Hosting deploya da pasta `firebase/public/` mas o build do Flutter vai para `pwa_cliente/build/web/`

**SE NÃO COPIAR, VAI DEPLOYAR O BUILD ANTIGO E DAR MERDA!**

## COMANDOS CORRETOS PARA DEPLOY

### 1. Build do PWA
```bash
cd /Users/joseairton/Downloads/GS/pwa_cliente
flutter clean
flutter pub get
flutter build web --release
```

### 2. COPIAR BUILD PARA PASTA PUBLIC (NÃO ESQUECER!)
```bash
rm -rf /Users/joseairton/Downloads/GS/firebase/public/*
cp -r /Users/joseairton/Downloads/GS/pwa_cliente/build/web/* /Users/joseairton/Downloads/GS/firebase/public/
```

### 3. Deploy no Firebase
```bash
cd /Users/joseairton/Downloads/GS/firebase
firebase deploy --only hosting
```

## CHECKLIST PRÉ-DEPLOY
- [ ] Fez flutter build web?
- [ ] COPIOU de `pwa_cliente/build/web/` para `firebase/public/`?
- [ ] Verificou data/hora dos arquivos em `firebase/public/`?
- [ ] Deploy com firebase deploy --only hosting?

## VERIFICAÇÃO PÓS-DEPLOY
```bash
ls -la /Users/joseairton/Downloads/GS/firebase/public/ | head -5
```
Verificar se os arquivos têm a data/hora ATUAL!

---
**NUNCA MAIS ESQUECER ESSE PASSO DA CÓPIA!**
