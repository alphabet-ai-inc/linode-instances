En **HashiCorp Vault**, una **política** es un conjunto de reglas que definen los permisos de acceso a los secretos y funcionalidades dentro de Vault.  

### 🔹 **¿Qué son las políticas en Vault?**  
Las políticas determinan:  
- **Qué rutas** (paths) dentro de Vault puede acceder un usuario o entidad.  
- **Qué operaciones** (como `read`, `write`, `list`, `delete`) están permitidas en esas rutas.  
- **Qué secretos** pueden ser gestionados.  

Se escriben en **HCL (HashiCorp Configuration Language)** o **JSON**.  

### 🔹 **Ejemplo de una política básica**  
```hcl
path "secret/data/mi-secreto" {
  capabilities = ["read", "list"]
}

path "secret/data/otro-secreto" {
  capabilities = ["create", "update", "delete"]
}
```
Esto permite:  
- Solo **leer y listar** en `secret/data/mi-secreto`.  
- **Crear, actualizar y borrar** en `secret/data/otro-secreto`.  

### 🔹 **Tipos de políticas en Vault**  
1. **Políticas ACL (Access Control Lists)** → Las más comunes, definen permisos sobre rutas.  
2. **Políticas RGPs (Role Governing Policies)** → Usadas con el sistema de identidad externa (como OIDC o LDAP).  
3. **Políticas de Entidad y Grupo** → Asignadas directamente a usuarios o grupos.  

### 🔹 **Cómo se asignan?**  
- A **tokens** (directamente).  
- A **métodos de autenticación** (usuarios LDAP, GitHub, JWT, etc.).  
- A **entidades/grupos** (en sistemas de identidad avanzados).  

### 🔹 **Comando para aplicar una política**  
```sh
vault policy write mi-politica mi-politica.hcl
```
Luego se asocia a un método de autenticación.  

### 🔹 **¿Dónde se usan?**  
- Controlar acceso a secretos (KV, databases, PKI, etc.).  
- Restringir operaciones administrativas.  
- Gestionar permisos en entornos multi-team.  
