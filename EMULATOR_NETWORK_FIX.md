# Fix: Emulador Android Sem Internet

## Problema
O emulador não consegue resolver DNS: `Unable to resolve host firestore.googleapis.com`

## Soluções

### Solução 1: Reiniciar o Emulador com DNS Personalizado
```bash
# Feche o emulador atual
# Depois inicie com DNS do Google:
emulator -avd <nome_do_avd> -dns-server 8.8.8.8,8.8.4.4
```

### Solução 2: Configurar DNS no Emulador
1. Abra as **Settings** no emulador
2. Vá em **Network & Internet** > **Wi-Fi**
3. Pressione e segure no **AndroidWiFi**
4. Selecione **Modify Network**
5. Expanda **Advanced Options**
6. Mude **IP Settings** para **Static**
7. Configure DNS:
   - **DNS 1**: `8.8.8.8`
   - **DNS 2**: `8.8.4.4`
8. Salve

### Solução 3: Resetar ADB e Emulador
```bash
# Mata todos os processos do emulador e ADB
adb kill-server
pkill -9 qemu-system
adb start-server

# Inicie o emulador novamente
```

### Solução 4: Usar Emulador com Rede de Ponte (Cold Boot)
1. Feche o emulador
2. No Android Studio:
   - **Tools** > **Device Manager**
   - Clique no ⋮ ao lado do seu AVD
   - Selecione **Cold Boot Now**

### Solução 5: Verificar Firewall/VPN
- Desabilite temporariamente VPN ou firewall que possam estar bloqueando
- Verifique se o Mac tem internet funcionando

### Verificar se Funcionou
Após aplicar qualquer solução, teste no emulador:
```bash
# No terminal do emulador (Tools > Terminal no Android Studio)
ping 8.8.8.8
ping google.com
```

Se ambos funcionarem, reinicie o app Flutter.
