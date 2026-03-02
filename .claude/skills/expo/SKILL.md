---
name: expo
description: Comprehensive Expo / React Native development guide covering native UI, Expo Router, API routes, Tailwind CSS setup, data fetching, DOM components, deployment, CI/CD workflows, and SDK upgrades. Use when building React Native / Expo apps. Source - expo/skills official partner repository.
tools: Read, Write, Edit, Bash, Glob, Grep
---

# Expo Development Guide

Comprehensive guide for building apps with Expo and React Native. Source: `expo/skills` official partner repository.

## Building Native UI

### Expo Router Navigation

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router';

export default function Layout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'Home' }} />
      <Stack.Screen name="details" options={{ title: 'Details' }} />
    </Stack>
  );
}
```

### Native Tabs

```typescript
import { Tabs } from 'expo-router';
import { TabBarIcon } from '@/components/TabBarIcon';

export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="index" options={{
        title: 'Home',
        tabBarIcon: ({ color }) => <TabBarIcon name="home" color={color} />,
      }} />
    </Tabs>
  );
}
```

### Styling Best Practices

- Use `StyleSheet.create()` for performance
- Prefer `flexbox` for layouts
- Use `Platform.select()` for platform-specific styles
- Consider NativeWind (Tailwind) for utility-first approach

### Animations

```typescript
import Animated, { useSharedValue, useAnimatedStyle, withSpring } from 'react-native-reanimated';

function AnimatedComponent() {
  const scale = useSharedValue(1);
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: withSpring(scale.value) }],
  }));

  return <Animated.View style={animatedStyle} />;
}
```

---

## API Routes (Expo Router)

```typescript
// app/api/hello+api.ts
export async function GET(request: Request) {
  return Response.json({ message: 'Hello World' });
}

export async function POST(request: Request) {
  const body = await request.json();
  return Response.json({ received: body });
}
```

### Dynamic Routes

```typescript
// app/api/users/[id]+api.ts
export async function GET(request: Request, { id }: { id: string }) {
  return Response.json({ userId: id });
}
```

### Environment Variables

```bash
# .env
API_KEY=your_key_here
```

Access via `process.env.API_KEY` in API routes.

---

## Tailwind CSS Setup (NativeWind v5)

```bash
npx expo install nativewind tailwindcss react-native-css
```

### Configuration

```javascript
// tailwind.config.js
module.exports = {
  content: ['./app/**/*.{js,jsx,ts,tsx}', './components/**/*.{js,jsx,ts,tsx}'],
  presets: [require('nativewind/preset')],
  theme: { extend: {} },
};
```

### Usage

```typescript
import { View, Text } from 'react-native';

export default function Screen() {
  return (
    <View className="flex-1 items-center justify-center bg-white">
      <Text className="text-xl font-bold text-gray-900">Hello</Text>
    </View>
  );
}
```

### Platform-Specific Styles

```typescript
<View className="p-4 ios:bg-blue-500 android:bg-green-500 web:bg-red-500" />
```

---

## Data Fetching

### React Query Pattern (Recommended)

```typescript
import { useQuery, useMutation, QueryClient, QueryClientProvider } from '@tanstack/react-query';

function useUser(id: string) {
  return useQuery({
    queryKey: ['user', id],
    queryFn: () => fetch(`/api/users/${id}`).then(r => r.json()),
  });
}
```

### Authentication with SecureStore

```typescript
import * as SecureStore from 'expo-secure-store';

async function getAuthToken() {
  return await SecureStore.getItemAsync('auth_token');
}

async function authenticatedFetch(url: string) {
  const token = await getAuthToken();
  return fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });
}
```

### Offline Support

- Use React Query's `persistQueryClient` for cache persistence
- Handle network errors gracefully with retry logic
- Show stale data while revalidating

---

## DOM Components (`use dom`)

Run web code in native webviews:

```typescript
'use dom';

export default function WebChart({ data }: { data: number[] }) {
  // This runs in a webview - can use any web library
  return <canvas id="chart" />;
}
```

Use for:
- Web-only libraries (D3.js, Chart.js, etc.)
- Complex HTML rendering
- Existing web components

---

## Deployment

### EAS Build

```bash
# Install EAS CLI
npm install -g eas-cli

# Configure
eas build:configure

# Build for stores
eas build --platform ios
eas build --platform android

# Submit to stores
eas submit --platform ios
eas submit --platform android
```

### EAS Hosting (Web)

```bash
# Deploy web app
npx expo export --platform web
eas deploy
```

### Over-the-Air Updates

```bash
eas update --branch production --message "Bug fix"
```

---

## CI/CD Workflows (EAS Workflow)

```yaml
# .eas/workflows/build-and-submit.yaml
name: Build and Submit
on:
  push:
    branches: [main]

jobs:
  build-ios:
    type: build
    platform: ios
    profile: production

  build-android:
    type: build
    platform: android
    profile: production

  submit-ios:
    type: submit
    platform: ios
    needs: [build-ios]

  submit-android:
    type: submit
    platform: android
    needs: [build-android]
```

---

## SDK Upgrades

### Upgrade Command

```bash
npx expo install --fix
```

### Common Breaking Changes (Check for Each Upgrade)

- React version changes (React 19 may require updates)
- New Architecture migration
- Deprecated packages removal
- NativeWind/NativeTabs API changes
- React Compiler compatibility

### Upgrade Checklist

1. Read the upgrade guide for your target SDK version
2. Run `npx expo install --fix` to update packages
3. Check for deprecated packages and replace them
4. Run `npx expo prebuild --clean` to regenerate native code
5. Test on both iOS and Android
6. Update CI/CD workflows if needed
