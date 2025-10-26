#!/usr/bin/env python3
"""
Script to update KML file with 2023 plaque data from JSON.

This script:
1. Analyzes the existing blueplaques.kml file
2. Analyzes the 2023.json file with updated plaque data
3. Creates a new KML file based on the 2023 data

Improvements:
- Eliminates code duplication through extracted methods
- Properly handles HTML entity encoding using CDATA sections
- Corrects style URL naming to match iOS app expectations (#blueStyle, #greyStyle)
- Validates plaque data quality
"""

import json
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import List, Dict, Any
from collections import defaultdict
import html
import re


class KMLPlaquAnalyzer:
    """Analyze and process blue plaque data in KML and JSON formats."""

    def __init__(self, workspace_dir: str):
        self.workspace_dir = Path(workspace_dir)
        self.kml_file = self.workspace_dir / "blueplaques.kml"
        self.json_file = self.workspace_dir / "2023.json"
        # Track validation warnings
        self.validation_warnings = []

    def analyze_kml(self) -> Dict[str, Any]:
        """Analyze the existing KML file and count plaques."""
        print("\n" + "=" * 60)
        print("ANALYZING KML FILE")
        print("=" * 60)

        tree = ET.parse(self.kml_file)
        root = tree.getroot()

        # Define namespaces
        namespaces = {
            "kml": "http://www.opengis.net/kml/2.2",
            "gx": "http://www.google.com/kml/ext/2.2",
        }

        # Find all Placemarks
        placemarks = root.findall(".//kml:Placemark", namespaces)
        plaques_by_area = defaultdict(list)

        for placemark in placemarks:
            name_elem = placemark.find("kml:name", namespaces)
            desc_elem = placemark.find("kml:description", namespaces)

            if name_elem is not None:
                name = name_elem.text or "Unknown"
                description = desc_elem.text if desc_elem is not None else ""

                # Get parent folder name (area)
                parent = placemark
                area_name = "Unknown"
                for ancestor in root.iter():
                    if placemark in ancestor.findall(".//kml:Placemark", namespaces):
                        folder = ancestor.find("kml:name", namespaces)
                        if folder is not None and folder.text:
                            area_name = folder.text

                plaques_by_area[area_name].append(name)

        total_plaques = sum(len(plaques) for plaques in plaques_by_area.values())

        print(f"\nTotal plaques in KML: {total_plaques}")
        print(f"Total areas: {len(plaques_by_area)}")
        print("\nPlaques by area:")
        for area in sorted(plaques_by_area.keys()):
            print(f"  {area}: {len(plaques_by_area[area])} plaques")

        return {
            "total": total_plaques,
            "areas": plaques_by_area,
            "tree": tree,
            "root": root,
            "namespaces": namespaces,
        }

    def _extract_borough(self, address: str) -> str:
        """Extract postcode or area name from address for grouping.

        This is a shared utility method used by both analyze_json() and create_updated_kml()
        to ensure consistent borough grouping logic.
        """
        if not address:
            return "Other"

        # Split by comma and get the last part which usually contains postcode
        parts = [p.strip() for p in address.split(",")]

        # Try to find postcode in last parts
        for part in reversed(parts[-2:]):  # Check last 2 parts
            if not part:
                continue
            # Extract postcode prefix (e.g., "SW3", "N8", "E15")
            match = re.search(r'([A-Z]{1,2}\d{1,2}[A-Z]?)', part)
            if match:
                postcode_prefix = match.group(1)
                return postcode_prefix

        # If no postcode found, look for a meaningful place name
        for part in reversed(parts):
            if part and len(part) > 2 and part[0].isupper() and not part[0].isdigit():
                # Skip very short parts and common words
                if not any(part.lower().startswith(w) for w in ['the ', 'near ', 'off ', 'at ', 'by ', 'on ']):
                    # Return if it's not just a street name
                    if not any(part.lower().endswith(w) for w in ['street', 'road', 'avenue', 'lane', 'court', 'drive', 'place', 'terrace', 'square', 'road', 'mews', 'yard']):
                        return part

        return "Other"

    def _group_plaques_by_borough(self, plaques: List[Dict[str, Any]]) -> Dict[str, List[Dict[str, Any]]]:
        """Group plaques by borough, extracted from address.

        This is a shared utility method used by both analyze_json() and create_updated_kml()
        to ensure consistent grouping logic.
        """
        plaques_by_borough = defaultdict(list)
        for plaque in plaques:
            address = plaque.get("address", "")
            borough = self._extract_borough(address)
            plaques_by_borough[borough].append(plaque)
        return plaques_by_borough

    def analyze_json(self) -> Dict[str, Any]:
        """Analyze the JSON file and count plaques."""
        print("\n" + "=" * 60)
        print("ANALYZING JSON FILE")
        print("=" * 60)

        with open(self.json_file, "r") as f:
            plaques_data = json.load(f)

        plaques_by_area = defaultdict(list)
        plaques_by_colour = defaultdict(int)
        plaques_by_borough = self._group_plaques_by_borough(plaques_data)

        for plaque in plaques_data:
            area = plaque.get("area", {})
            area_name = area.get("name", "Unknown") if isinstance(area, dict) else "Unknown"
            colour = plaque.get("colour_name", "unknown")
            title = plaque.get("title", "Unknown")

            plaques_by_area[area_name].append(title)
            plaques_by_colour[colour] += 1

        total_plaques = len(plaques_data)

        print(f"\nTotal plaques in JSON: {total_plaques}")
        print(f"Total areas: {len(plaques_by_area)}")
        print("\nPlaques by colour:")
        for colour in sorted(plaques_by_colour.keys(), key=lambda x: (x is None, x)):
            print(f"  {colour}: {plaques_by_colour[colour]} plaques")
        print("\nPlaques by area:")
        for area in sorted(plaques_by_area.keys()):
            print(f"  {area}: {len(plaques_by_area[area])} plaques")

        print("\nPlaques by borough (extracted from address):")
        for borough in sorted(plaques_by_borough.keys()):
            print(f"  {borough}: {len(plaques_by_borough[borough])} plaques")

        return {
            "total": total_plaques,
            "areas": plaques_by_area,
            "boroughs": plaques_by_borough,
            "colour_distribution": plaques_by_colour,
            "plaques": plaques_data,
        }

    def create_updated_kml(self, json_data: Dict[str, Any]) -> tuple:
        """Create a new KML file based on the 2023 JSON data.

        The generated KML includes:
        - Proper HTML formatting in descriptions (no escaped entities)
        - Style references that match iOS app expectations
        - Organized folder structure by borough
        - Validation warnings for data quality issues
        """
        print("\n" + "=" * 60)
        print("CREATING UPDATED KML FILE")
        print("=" * 60)

        # Create root KML structure
        kml_ns = "http://www.opengis.net/kml/2.2"
        gx_ns = "http://www.google.com/kml/ext/2.2"
        atom_ns = "http://www.w3.org/2005/Atom"

        # Register namespaces
        ET.register_namespace("", kml_ns)
        ET.register_namespace("gx", gx_ns)
        ET.register_namespace("atom", atom_ns)

        kml = ET.Element("kml", xmlns=kml_ns)
        kml.set("{http://www.w3.org/2000/xmlns/}gx", gx_ns)
        kml.set("{http://www.w3.org/2000/xmlns/}atom", atom_ns)

        document = ET.SubElement(kml, "Document")
        name_elem = ET.SubElement(document, "name")
        name_elem.text = "Blue Plaques"

        # Add styles
        self._add_styles(document)

        # Group plaques by borough (reuses logic from analyze_json)
        plaques_by_borough = self._group_plaques_by_borough(json_data["plaques"])

        # Create folder for all plaques
        main_folder = ET.SubElement(document, "Folder")
        main_folder_name = ET.SubElement(main_folder, "name")
        main_folder_name.text = "Blue Plaques"

        # Add placemarks for each plaque organized by borough
        plaque_count = 0
        skipped_no_address = 0

        for borough_name in sorted(plaques_by_borough.keys()):
            borough_folder = ET.SubElement(main_folder, "Folder")
            borough_folder_name = ET.SubElement(borough_folder, "name")
            borough_folder_name.text = borough_name

            for plaque in plaques_by_borough[borough_name]:
                # Skip plaques without an address - they're incomplete
                address = plaque.get("address") or ""
                if not address.strip():
                    title = plaque.get("title", "Unknown")
                    self.validation_warnings.insert(0, f"SKIPPED: '{title}' - no address (incomplete data)")
                    skipped_no_address += 1
                    continue

                self._add_placemark(borough_folder, plaque)
                plaque_count += 1

        # Format and save
        tree = ET.ElementTree(kml)
        output_file = self.workspace_dir / "blueplaques_updated.kml"

        # Pretty print
        self._indent(kml)

        # Write to temporary string first
        import io
        temp_output = io.StringIO()
        tree.write(temp_output, encoding="unicode", xml_declaration=False)
        xml_content = temp_output.getvalue()

        # Post-process to add CDATA sections around descriptions
        # This makes the KML match the original format and preserves literal <br> tags within CDATA
        # Pattern matches description elements with any content (including entities and escaped brackets)
        import re
        def wrap_in_cdata(match):
            content = match.group(1)
            # Unescape the content so <br> tags are literal within CDATA
            # Within CDATA, we need literal <br> not escaped entities
            content = content.replace('&lt;br&gt;', '<br>')
            content = content.replace('&lt;br /&gt;', '<br>')
            content = content.replace('&apos;', "'")
            content = content.replace('&quot;', '"')
            # &amp; should stay as &amp; (it's a literal ampersand representation)
            # But HTML entities like &amp; for single & should remain
            return f'<description><![CDATA[{content}]]></description>'

        xml_content = re.sub(
            r'<description>(.+?)</description>',
            wrap_in_cdata,
            xml_content,
            flags=re.DOTALL
        )

        # Write to file with proper XML declaration
        with open(output_file, 'w', encoding='UTF-8') as f:
            f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
            f.write(xml_content)

        print(f"\nCreated updated KML file: {output_file}")
        print(f"Total placemarks created: {plaque_count}")
        print(f"Plaques skipped (no address): {skipped_no_address}")

        return (str(output_file), plaque_count, skipped_no_address)

    def _create_style(self, document: ET.Element, style_id: str, icon_url: str) -> None:
        """Create a style element with icon configuration.

        Extracted method to reduce duplication between blue and grey styles.
        """
        style = ET.SubElement(document, "Style", id=style_id)
        icon_style = ET.SubElement(style, "IconStyle")
        scale = ET.SubElement(icon_style, "scale")
        scale.text = "1.15"
        icon = ET.SubElement(icon_style, "Icon")
        href = ET.SubElement(icon, "href")
        href.text = icon_url
        ET.SubElement(icon_style, "hotSpot", x="32", y="1", xunits="pixels", yunits="pixels")

    def _add_styles(self, document: ET.Element) -> None:
        """Add styling information to the KML document.

        Note: Style IDs (blueStyle, greyStyle) correspond to the iOS app expectations.
        The iOS app uses these styleUrl values to determine marker colors.
        """
        # Blue plaque style - uses blue circle icon
        self._create_style(document, "blueStyle", "http://maps.google.com/mapfiles/kml/paddle/blu-circle.png")

        # Grey plaque style - uses red circle icon (for non-blue plaques)
        self._create_style(document, "greyStyle", "http://maps.google.com/mapfiles/kml/paddle/red-circle.png")

    def _capitalize_after_br(self, text: str) -> str:
        """Capitalize the first letter after each <br> tag.

        Ensures proper formatting for descriptions like:
        "inscription<br>address<br>administered by..."
        becomes:
        "inscription<br>Address<br>Administered by..."
        """
        if not text:
            return text

        import re
        # Replace <br> followed by lowercase letter with <br> + UPPERCASE letter
        def capitalize_match(match):
            br_tag = match.group(1)
            first_char = match.group(2).upper()
            rest = match.group(3)
            return f"{br_tag}{first_char}{rest}"

        # Pattern: <br> followed by optional whitespace, then a lowercase letter
        capitalized = re.sub(r'(<br>)\s*([a-z])(.*?)(?=<br>|$)', capitalize_match, text, flags=re.IGNORECASE)
        return capitalized

    def _clean_description_text(self, text: str) -> str:
        """Clean and unescape HTML entities from description text.

        Removes escaped HTML entities like &lt;br&gt; and converts them to actual HTML.
        Also handles multiple spaces and normalizes whitespace while preserving
        line breaks.

        This prevents double-encoding issues in the KML file.
        """
        if not text:
            return text

        # First, unescape HTML entities (e.g., &lt;br&gt; -> <br>)
        cleaned = html.unescape(text)

        # Replace escaped line breaks with actual br tags
        cleaned = cleaned.replace('&lt;br&gt;', '<br>')
        cleaned = cleaned.replace('&lt;br /&gt;', '<br>')
        cleaned = cleaned.replace('\\n', '<br>')

        # Remove extra whitespace while preserving intentional formatting
        # Split by <br> to preserve formatting, clean each part, then rejoin
        parts = cleaned.split('<br>')
        cleaned_parts = []
        for part in parts:
            # Remove extra spaces from each part
            cleaned_part = re.sub(r'\s+', ' ', part).strip()
            if cleaned_part:
                cleaned_parts.append(cleaned_part)

        # Rejoin with <br> tags
        cleaned = '<br>'.join(cleaned_parts) if cleaned_parts else ""

        return cleaned

    def _extract_clean_title(self, plaque: Dict[str, Any]) -> str:
        """Extract a clean title/name for the plaque.

        The JSON 'title' field often contains "[name] [colour] plaque" which is not
        suitable for display. We prefer:
        1. The 'subjects' field (clean name without colour/plaque)
        2. The 'title' field with colour+plaque stripped
        3. The raw title as fallback

        This ensures plaque names display as "Jacob von Hogflume" instead of
        "Jacob von Hogflume blue plaque".
        """
        # First choice: use subjects field if available
        subjects = plaque.get("subjects")
        if subjects and isinstance(subjects, str) and subjects.strip():
            return subjects.strip()

        # Second choice: clean the title by removing colour + plaque suffix
        title = plaque.get("title") or ""
        if not title:
            return "Unknown"

        title = title.strip()

        # Pattern: remove " [colour] plaque" from the end completely
        import re
        # Match common colour names at the end: " [colour] plaque$"
        colour_pattern = r'\s+(blue|green|grey|gray|red|black|white|bronze|brass|silver|gold|brown|stone|marble|slate|wood|claret|film cell|brushed metal|clear|pink|purple|orange|yellow|terracotta|multicoloured|maroon|red and black|green and red)\s+plaque$'
        cleaned = re.sub(colour_pattern, '', title, flags=re.IGNORECASE)

        # Also handle pattern: "... plaque" with no colour suffix - but only if there's substance before it
        # (don't remove "plaque" if it's the whole thing like "plaque № 10003")
        if cleaned == title and re.match(r'^[a-z]', title, re.IGNORECASE):
            # Handle both single and multi-word colours
            multi_colour_pattern = r'^(film cell|brushed metal|red and black|green and red|blue|green|grey|gray|red|black|white|bronze|brass|silver|gold|brown|stone|marble|slate|wood|claret|clear|pink|purple|orange|yellow|terracotta|multicoloured|maroon)\s+plaque\s+'
            match = re.match(multi_colour_pattern, title, re.IGNORECASE)
            if match:
                cleaned = title[len(match.group(0)):].strip()
                # Prepend "plaque " back for institutional plaques
                cleaned = "plaque " + cleaned

        return cleaned if cleaned else title

    def _extract_council_and_year(self, plaque: Dict[str, Any]) -> str:
        """Extract council and year from available data.

        Attempts to extract council name and year from:
        1. organisations list
        2. erected_at date
        3. area name

        Falls back to generic text if insufficient data.
        """
        council = ""
        year = ""

        # Try to get year from erected_at
        erected = plaque.get("erected_at") or ""
        if erected and len(erected) >= 4:
            year = erected[:4]

        # Try to get council from organisations
        organisations = plaque.get("organisations", [])
        if organisations and isinstance(organisations, list) and len(organisations) > 0:
            org = organisations[0]
            if isinstance(org, dict):
                council = org.get("name", "")

        # Fallback: construct council name from area
        if not council:
            area = plaque.get("area", {})
            if isinstance(area, dict):
                council = area.get("name", "London")

        # Combine council and year
        if council and year:
            return f"{council} {year}"
        elif council:
            return council
        elif year:
            return year
        else:
            return ""

    def _build_description(self, plaque: Dict[str, Any]) -> str:
        """Build a clean, well-formatted description for the plaque.

        Format matches iOS parsing expectations (NSString+BPLPlacemarkFeatureDescription):
        Line 1: Title/Name with dates<br>
        Line 2: Occupation/Details<br>
        Line 3: Address<br>
        Line 4: Council and Year

        This format allows the iOS parser to correctly split and extract:
        - name: everything before first '('
        - occupation: content between first and second <br>
        - address: content between second and third <br>
        - councilAndYear: final content after third <br>
        """
        parts = []

        # Line 1: Title (clean name without "[colour] plaque" suffix)
        title = self._extract_clean_title(plaque)
        if title:
            title = self._clean_description_text(title)
            parts.append(title)

        # Line 2: Occupation/Details (main inscription/description)
        inscription = plaque.get("inscription") or ""
        inscription = inscription.strip() if inscription else ""
        if inscription:
            inscription = self._clean_description_text(inscription)
            parts.append(f"<br>{inscription}")

        # Line 3: Address
        address = plaque.get("address") or ""
        address = address.strip() if address else ""
        if address:
            address = self._clean_description_text(address)
            parts.append(f"<br>{address}")

        # Line 4: Council and Year
        council_and_year = self._extract_council_and_year(plaque)
        if council_and_year:
            parts.append(f"<br>{council_and_year}")

        # Combine all parts and capitalize text after <br> tags
        description = "".join(parts)
        description = self._capitalize_after_br(description)
        return description

    def _validate_plaque_data(self, plaque: Dict[str, Any]) -> List[str]:
        """Validate plaque data and return list of warnings for this plaque.

        Checks for:
        - Missing inscription
        - Very long inscriptions that might display poorly
        - Missing coordinates
        - Missing dates
        - Multiple people (which might indicate complex formatting needs)

        Note: Plaques with missing addresses are skipped entirely before validation.
        """
        warnings = []
        title = plaque.get("title", "Unknown")

        # Check for missing inscription
        inscription = plaque.get("inscription") or ""
        if not inscription.strip():
            warnings.append(f"'{title}' - missing inscription/description")

        # Check for very long inscription (might affect layout)
        if inscription and len(inscription) > 600:
            warnings.append(f"'{title}' - very long inscription ({len(inscription)} chars, may affect display)")

        # Check for missing colour
        colour = plaque.get("colour_name") or ""
        if not colour.strip():
            warnings.append(f"'{title}' - missing colour_name (will default to blue)")

        # Check for missing coordinates
        lat = plaque.get("latitude")
        lon = plaque.get("longitude")
        if lat is None or lon is None:
            warnings.append(f"'{title}' - missing coordinates (won't appear on map)")

        # Check for missing erected date
        erected = plaque.get("erected_at") or ""
        if not erected.strip():
            warnings.append(f"'{title}' - missing erected_at date")

        # Check for multiple people (complex entries)
        people = plaque.get("people", [])
        if isinstance(people, list) and len(people) > 2:
            warnings.append(f"'{title}' - {len(people)} people listed (complex entry, check formatting)")

        # Check for special characters that might cause parsing issues
        inscription_text = inscription or ""
        if inscription_text and len(inscription_text) > 0:
            # Look for patterns that might indicate parsing issues
            if "<" in inscription_text or ">" in inscription_text:
                warnings.append(f"'{title}' - contains < or > characters that may cause parsing issues")

        return warnings

    def _add_placemark(self, folder: ET.Element, plaque: Dict[str, Any]) -> None:
        """Add a single plaque as a Placemark to the KML.

        Creates a well-formed KML Placemark with:
        - Title from plaque data
        - Description with proper HTML formatting (format: Title<br>Inscription<br>Address<br>Council/Year)
        - Coordinates and LookAt for map navigation
        - Style reference matching iOS app expectations

        Also validates data and logs any quality concerns.
        """
        # Validate data and collect warnings
        data_warnings = self._validate_plaque_data(plaque)
        if data_warnings:
            self.validation_warnings.extend(data_warnings)

        placemark = ET.SubElement(folder, "Placemark")

        # Name - use clean title without "[colour] plaque" suffix
        name_elem = ET.SubElement(placemark, "name")
        title = self._extract_clean_title(plaque)
        name_elem.text = self._clean_description_text(title)

        # Description - using CDATA section to preserve HTML formatting
        # Format: Title<br>Inscription<br>Address<br>Council/Year
        # This matches iOS parser expectations in NSString+BPLPlacemarkFeatureDescription
        desc_text = self._build_description(plaque)

        # Create description element with properly handled text
        desc_elem = ET.SubElement(placemark, "description")
        desc_elem.text = desc_text

        # Coordinates
        latitude = plaque.get("latitude")
        longitude = plaque.get("longitude")

        if latitude is not None and longitude is not None:
            point = ET.SubElement(placemark, "Point")
            coordinates = ET.SubElement(point, "coordinates")
            coordinates.text = f"{longitude},{latitude},0"

            # LookAt (optional) - helps with initial map positioning
            lookat = ET.SubElement(placemark, "LookAt")
            lookat_lon = ET.SubElement(lookat, "longitude")
            lookat_lon.text = str(longitude)
            lookat_lat = ET.SubElement(lookat, "latitude")
            lookat_lat.text = str(latitude)
            lookat_alt = ET.SubElement(lookat, "altitude")
            lookat_alt.text = "0"
            lookat_heading = ET.SubElement(lookat, "heading")
            lookat_heading.text = "0"
            lookat_tilt = ET.SubElement(lookat, "tilt")
            lookat_tilt.text = "0"
            lookat_range = ET.SubElement(lookat, "range")
            lookat_range.text = "500"

        # Style reference - determines marker color in iOS app
        style_url = ET.SubElement(placemark, "styleUrl")
        colour_name = (plaque.get("colour_name") or "blue").lower().strip()

        # Map colour names to style IDs that iOS app recognizes
        if colour_name in ("blue", "blueStyle"):
            style_url.text = "#blueStyle"
        else:
            # All other colours (green, grey, etc.) use greyStyle
            style_url.text = "#greyStyle"

    def _indent(self, elem: ET.Element, level: int = 0) -> None:
        """Add pretty-print indentation to XML."""
        indent_str = "\n" + level * "\t"
        if len(elem):
            if not elem.text or not elem.text.strip():
                elem.text = indent_str + "\t"
            if not elem.tail or not elem.tail.strip():
                elem.tail = indent_str
            for child in elem:
                self._indent(child, level + 1)
            if not child.tail or not child.tail.strip():
                child.tail = indent_str
        else:
            if level and (not elem.tail or not elem.tail.strip()):
                elem.tail = indent_str

    def generate_report(self) -> None:
        """Generate a comprehensive report including data quality validation."""
        print("\n" + "=" * 60)
        print("BLUE PLAQUES UPDATE REPORT")
        print("=" * 60)

        # Analyze KML
        kml_data = self.analyze_kml()

        # Analyze JSON
        json_data = self.analyze_json()

        # Compare
        print("\n" + "=" * 60)
        print("COMPARISON")
        print("=" * 60)
        print(f"\nPlaques in KML: {kml_data['total']}")
        print(f"Plaques in JSON: {json_data['total']}")
        print(f"New plaques in 2023: {json_data['total'] - kml_data['total']}")

        # Create updated KML
        output_file, plaque_count, skipped_no_address = self.create_updated_kml(json_data)

        # Print validation warnings if any
        if self.validation_warnings:
            print("\n" + "=" * 60)
            print("DATA QUALITY WARNINGS & OUTLIERS")
            print("=" * 60)
            print(f"\nFound {len(self.validation_warnings)} total issues across all plaques:")

            # Organize warnings by type
            warning_types = defaultdict(list)
            for warning in self.validation_warnings:
                if "missing address" in warning:
                    warning_types["Missing Address"].append(warning)
                elif "missing inscription" in warning:
                    warning_types["Missing Inscription"].append(warning)
                elif "very long inscription" in warning:
                    warning_types["Very Long Inscription"].append(warning)
                elif "missing colour" in warning:
                    warning_types["Missing Colour"].append(warning)
                elif "missing coordinates" in warning:
                    warning_types["Missing Coordinates"].append(warning)
                elif "missing erected_at" in warning:
                    warning_types["Missing Erected Date"].append(warning)
                elif "people listed" in warning:
                    warning_types["Complex Entry (Multiple People)"].append(warning)
                elif "special characters" in warning:
                    warning_types["Special Characters"].append(warning)
                else:
                    warning_types["Other"].append(warning)

            # Print organized warnings
            for warn_type in sorted(warning_types.keys()):
                warnings = warning_types[warn_type]
                print(f"\n{warn_type}: {len(warnings)} plaques")
                # Show first 3-5 examples depending on severity
                limit = 3 if warn_type in ["Very Long Inscription", "Complex Entry (Multiple People)"] else 5
                for warning in warnings[:limit]:
                    print(f"  ⚠️  {warning}")
                if len(warnings) > limit:
                    print(f"  ... and {len(warnings) - limit} more")

        print("\n" + "=" * 60)
        print("SUMMARY")
        print("=" * 60)
        print(f"\nOriginal KML file: {self.kml_file}")
        print(f"Updated KML file: {output_file}")
        print(f"\nTotal plaques in JSON data: {json_data['total']}")
        print(f"Plaques included in output: {plaque_count}")
        print(f"Plaques removed (no address): {skipped_no_address}")
        print(f"from {len(json_data['areas'])} London areas.")
        print(f"\nKey improvements in updated file:")
        print(f"  ✓ Descriptions formatted as: Title<br>Inscription<br>Address<br>Council/Year")
        print(f"  ✓ HTML entities properly unescaped by iOS app")
        print(f"  ✓ Style URLs match iOS app expectations (#blueStyle, #greyStyle)")
        print(f"  ✓ Incomplete entries (no address) removed")
        print(f"  ✓ Data quality validation for outliers")


def main():
    """Main entry point."""
    workspace_dir = "/Users/seanoshea/github/BluePlaquesLondon/BluePlaquesLondon/Resources"
    analyzer = KMLPlaquAnalyzer(workspace_dir)
    analyzer.generate_report()


if __name__ == "__main__":
    main()
