import { expect, test } from '@playwright/test';
import path from 'node:path';

const baseUrl = process.env.DEMO_BASE_URL;
if (!baseUrl) throw new Error('Set DEMO_BASE_URL to the healthy local application URL.');

const repositoryRoot = path.resolve(__dirname, '..');

test.setTimeout(300_000);

test.use({
  viewport: { width: 1280, height: 720 },
  video: { mode: 'on', size: { width: 1280, height: 720 } },
});

test('ParkAlert safe local lifecycle walkthrough', async ({ page }) => {
  await page.goto(baseUrl, { waitUntil: 'domcontentloaded' });
  await page.locator('flutter-view canvas').waitFor({
    state: 'attached',
    timeout: 30_000,
  });
  const semantics = page.locator('flt-semantics-placeholder');
  if (await semantics.count()) await semantics.evaluate((element) => element.click());

  await expect(page.getByText('SYNTHETIC / LOCAL / NOT SENT')).toBeVisible({
    timeout: 30_000,
  });
  await page.screenshot({ path: path.join(repositoryRoot, 'docs/assets/screenshots/overview.png') });
  await page.screenshot({ path: path.join(repositoryRoot, 'docs/demo/demo-thumbnail.png') });
  await page.waitForTimeout(22_000);

  await page.getByText('PA-DEMO-1042').scrollIntoViewIfNeeded();
  await page.waitForTimeout(23_000);

  await page.getByText('Blocking exit', { exact: true }).click();
  await page.getByLabel('Optional synthetic note').fill('Please move when safe. Synthetic demo only.');
  await page.waitForTimeout(30_000);

  await page.getByText('Prepare local alert preview').click();
  await expect(page.getByText('Add to simulated owner inbox')).toBeVisible();
  await page.mouse.move(640, 600);
  await page.mouse.wheel(0, 650);
  await page.waitForTimeout(30_000);

  await page.getByText('Add to simulated owner inbox').click();
  await expect(page.getByText('Resolve', { exact: true })).toBeVisible();
  await page.mouse.move(640, 600);
  await page.mouse.wheel(0, 500);
  await page.waitForTimeout(15_000);

  await page.getByText('Resolve', { exact: true }).click();
  await expect(page.getByText('RESOLVED')).toBeVisible();
  await page.waitForTimeout(15_000);

  await page.getByText('Inspect local activity').click();
  await expect(page.getByText('Activity log')).toBeVisible();
  await page.waitForTimeout(13_000);
  await page.goBack();
  await expect(page.getByText('ParkAlert safe simulation')).toBeVisible();

  await page.getByText('Inspect simulation controls').click();
  await expect(page.getByText('Demo settings')).toBeVisible();
  await page.waitForTimeout(12_000);
  await page.goBack();
  await page.mouse.move(640, 360);
  await page.mouse.wheel(0, -2_000);
  await page.waitForTimeout(29_000);
});
