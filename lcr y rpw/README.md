### Reporte del Código: LCR_RPW_Encapsulated.R
![Rplot07](https://github.com/jchicatti/optimization/assets/56322123/db01faa2-2a4c-4653-8059-d287610340b6)
> Figura 1. Grafo de árbol de las tareas del archivo instance_n=100_1.alb

**Objetivo y Contexto del Código**

El script LCR_RPW_Encapsulated.R ha sido diseñado para optimizar la asignación de tareas en entornos de producción utilizando dos algoritmos heurísticos conocidos: Regla del Candidato Mayor (LCR) y Ponderación de Posición Clasificada (RPW). Estos métodos son fundamentales en la ingeniería de sistemas y operaciones para mejorar la eficiencia en líneas de montaje o cualquier contexto donde las tareas deben distribuirse efectivamente entre estaciones de trabajo.

**Descripción General de los Algoritmos**

- **LCR (Largest Candidate Rule)**: Este algoritmo selecciona tareas basándose en su duración, comenzando con la más larga disponible que no supere el tiempo ciclo de la estación de trabajo actual, asegurando que todas las dependencias de precedencia estén satisfechas antes de su asignación.
  
- **RPW (Ranked Positional Weighting)**: RPW calcula un peso para cada tarea, que es la suma de su duración más los pesos de todas las tareas que directa o indirectamente dependen de ella. Este método proporciona una medida de la importancia de completar una tarea temprano debido a su impacto en las subsiguientes.

**Estructura de Datos**

Las tareas se manejan como nodos en una lista enlazada, donde cada nodo contiene:
- **Sucesores**: Lista de tareas que dependen directamente de la tarea actual.
- **Predecesores**: Lista de tareas que deben completarse antes de que la tarea actual pueda comenzar.
- **Tiempo de Tarea**: Duración necesaria para completar la tarea.

Esta estructura facilita la implementación de los algoritmos LCR y RPW, permitiendo recorrer fácilmente las dependencias de cada tarea.

**Funcionalidad del Código**

1. **Lectura de Datos**: El código está preparado para leer un archivo que contiene una serie de tareas, cada una con sus respectivos sucesores, predecesores y tiempo estimado de duración. La cantidad de tareas puede variar, y el formato del archivo debe estar correctamente estructurado para ser interpretado por el script.

2. **Creación de la Variable `nodes`**: Una vez leídas las tareas, se crea una variable `nodes`, que es un arreglo donde cada índice representa una tarea y sus atributos asociados (sucesores, predecesores, tiempo de tarea).

3. **Implementación de Algoritmos**: Se implementan las funciones `perform_LCR` y `perform_RPW` que, utilizando la información de `nodes`, asignan tareas a estaciones de trabajo de manera que se minimice el tiempo inactivo y se respeten las relaciones de precedencia.

4. **Cálculo de Pesos RPW**: Se desarrolla una función recursiva para calcular los pesos de cada tarea según el método RPW, que luego influye en el orden de asignación de tareas.

5. **Visualización**: Finalmente, el script genera una representación gráfica de las dependencias entre tareas, facilitando la visualización de las relaciones de precedencia y la secuencia de trabajo propuesta.

**Decisiones de Diseño**

- Se optó por estructuras de datos enlazadas debido a su eficacia para manejar listas de elementos donde el acceso y la modificación de las relaciones entre elementos son frecuentes y críticos.
- La recursividad fue empleada para el cálculo de pesos en RPW para simplificar el manejo de dependencias múltiples y profundas entre tareas.

Este script provee una herramienta robusta para la planificación y optimización de tareas en ambientes productivos, combinando técnicas de programación avanzada con métodos operativos probados para mejorar significativamente la eficiencia operativa.
**Inputs en R**
El usuario solamente debe de ingresar el nombre del archivo .ALB o cualquier otro archivo de texto y/o la ruta de dicho archivo de ser necesario.
**Outputs en R**
Las celdas quedan definidas en R y se almacenan en dos listas para LCR y RPW respectivamente. Cada una de estas listas, es a su vez una lista que almacena: las tareas que van en ella y el tiempo restante que le queda a la celda dadas las operaciones dentro de ella.
También se imprimen los valores de los pesos asignados según RPW.

![image](https://github.com/jchicatti/optimization/assets/56322123/94c7d034-2bc4-49aa-9a7d-585e256cb5d3)
Figura 2. Las primeras celdas asignadas segun LCR para el ejemplo  instance_n=100_1.alb

![image](https://github.com/jchicatti/optimization/assets/56322123/753445b9-83cf-4f6c-a0e2-ad79c198055d)
Figura 3. Las primeras celdas asignadas segun RPW para el ejemplo  instance_n=100_1.alb
