<script setup>
import { computed } from 'vue'

const props = defineProps({ value: Number, total: Number })
const pct = computed(() => props.total > 0 ? Math.round((props.value / props.total) * 100) : 0)
</script>

<template>
  <div>
    <div class="progress-bar">
      <div class="progress-fill" :style="{ width: pct + '%' }" />
    </div>
    <div style="display:flex;justify-content:space-between;margin-top:4px">
      <span style="font-size:10px;color:var(--text-3)">{{ value }} / {{ total }} p.</span>
      <span style="font-size:10px;color:var(--accent)">{{ pct }}%</span>
    </div>
  </div>
</template>
