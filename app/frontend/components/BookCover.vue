<script setup>
defineProps({ book: Object, fontSize: { type: Number, default: 40 } })
</script>

<template>
  <div :style="{ background: book.gradient || '#333', width: '100%', height: '100%', position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center', overflow: 'hidden' }">
    <img
      v-if="book.cover_url"
      :src="book.cover_url"
      :alt="book.title"
      style="position:absolute;inset:0;width:100%;height:100%;object-fit:cover"
    />
    <template v-else>
      <span :style="{ fontSize: fontSize + 'px', opacity: 0.9, position: 'relative', zIndex: 1 }">{{ book.emoji || '📖' }}</span>
      <div style="position:absolute;inset:0;background:linear-gradient(to bottom,transparent 40%,#00000060)" />
    </template>
  </div>
</template>
