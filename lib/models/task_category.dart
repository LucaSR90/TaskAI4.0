enum TaskCategory {
  trabajo('Trabajo'),
  personal('Personal'),
  estudio('Estudio'),
  urgente('Urgente');

  const TaskCategory(this.label);
  final String label;
}
