<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.22.4-Białowieża" styleCategories="Fields|Forms">
  <fieldConfiguration>
    <!-- cityobject atts -->
    <field name="ng_co_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="gmlid" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="gmlid_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="name" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="name_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="description" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="creation_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="termination_date" configurationFlags="None">
      <editWidget type="DateTime">
          <config>
            <Option type="Map">
              <Option name="allow_null" value="true" type="bool"/>
              <Option name="calendar_popup" value="true" type="bool"/>
              <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
              <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
              <Option name="field_iso_format" value="false" type="bool"/>
            </Option>
          </config>
      </editWidget>
    </field>
    <field name="relative_to_terrain" configurationFlags="None">
      <editWidget type="TextEdit">
          <config>
            <Option type="Map">
              <Option type="bool" name="AllowMulti" value="false"/>
              <Option type="bool" name="AllowNull" value="true"/>
              <Option type="QString" name="FilterExpression" value="data_model = 'CityGML 2.0' AND name = 'RelativeToTerrainType'"/>
              <Option type="QString" name="Key" value="value"/>
              <Option type="QString" name="Layer" value="_v_enumeration_value_"/>
              <Option type="int" name="NofColumns" value="1"/>
              <Option type="bool" name="OrderByValue" value="true"/>
              <Option type="bool" name="UseCompleter" value="false"/>
              <Option type="QString" name="Value" value="description"/>
            </Option>
          </config>
      </editWidget>
    </field>
    <field name="relative_to_water" configurationFlags="None">
      <editWidget type="TextEdit">
          <config>
            <Option type="Map">
              <Option type="bool" name="AllowMulti" value="false"/>
              <Option type="bool" name="AllowNull" value="true"/>
              <Option type="QString" name="FilterExpression" value="data_model = 'CityGML 2.0' AND name = 'RelativeToWaterType'"/>
              <Option type="QString" name="Key" value="value"/>
              <Option type="QString" name="Layer" value="_v_enumeration_value_"/>
              <Option type="int" name="NofColumns" value="1"/>
              <Option type="bool" name="OrderByValue" value="true"/>
              <Option type="bool" name="UseCompleter" value="false"/>
              <Option type="QString" name="Value" value="description"/>
            </Option>
          </config>
      </editWidget>
    </field>
    <field name="last_modification_date" configurationFlags="None">
      <editWidget type="DateTime">
          <config>
            <Option type="Map">
              <Option name="allow_null" value="true" type="bool"/>
              <Option name="calendar_popup" value="true" type="bool"/>
              <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
              <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
              <Option name="field_iso_format" value="false" type="bool"/>
            </Option>
          </config>
      </editWidget>
    </field>
    <field name="updating_person" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="reason_for_update" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="lineage" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <!-- thermalzone atts -->
    <field name="building_thermalzone_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="infiltrationrate" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="infiltrationrate_uom" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="iscooled" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="isheated" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="ng_co_id" index="0" name="Database ID (ng)"/>
    <alias field="id" index="1" name="Database ID"/>
    <alias field="gmlid" index="2" name="GML ID"/>
    <alias field="gmlid_codespace" index="3" name="GML ID Codespace"/>
    <alias field="name" index="4" name="Name"/>
    <alias field="name_codespace" index="5" name="Name Codespace"/>
    <alias field="description" index="6" name="Description"/>
    <alias field="creation_date" index="7" name="Creation Date"/>
    <alias field="termination_date" index="8" name="Termination Date"/>
    <alias field="relative_to_terrain" index="9" name="Relative to Terrain"/>
    <alias field="relative_to_water" index="10" name="Relative to Water"/>
    <alias field="last_modification_date" index="11" name="Last Modification Date"/>
    <alias field="updating_person" index="12" name="Updating Person"/>
    <alias field="reason_for_update" index="13" name="Reason for Update"/>
    <alias field="lineage" index="14" name="Lineage"/>
    <alias field="building_thermalzone_id" index="15" name="Building Thermalzone ID"/>
    <alias field="infiltrationrate" index="16" name="Infiltration Rate"/>
    <alias field="infiltrationrate_uom" index="17" name="Infiltration Rate UoM"/>
    <alias field="iscooled" index="18" name="Is Cooled"/>
    <alias field="isheated" index="19" name="Is Heated"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint unique_strength="1" notnull_strength="0" exp_strength="0" constraints="4" field="ng_co_id"/>
    <constraint unique_strength="1" notnull_strength="1" exp_strength="0" constraints="3" field="id"/>
    <constraint unique_strength="0" notnull_strength="1" exp_strength="0" constraints="3" field="building_thermalzone_id"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="1" constraints="4" field="infiltrationrate"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="1" constraints="4" field="infiltrationrate_uom"/>
    <constraint unique_strength="0" notnull_strength="1" exp_strength="0" constraints="4" field="iscooled"/>
    <constraint unique_strength="0" notnull_strength="1" exp_strength="0" constraints="4" field="isheated"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="(&quot;infiltrationrate&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;infiltrationrate_uom&quot;IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;infiltrationrate&quot;IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;infiltrationrate_uom&quot;IS NULL)" desc="Both values must either be NULL or NOT NULL" field="infiltrationrate"/>
    <constraint exp="(&quot;infiltrationrate&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;infiltrationrate_uom&quot;IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;infiltrationrate&quot;IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;infiltrationrate_uom&quot;IS NULL)" desc="Both values must either be NULL or NOT NULL" field="infiltrationrate_uom"/>
  </constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <!-- cityobject atts -->
  <attributeEditorForm>
    <attributeEditorContainer name="Main Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="id" showLabel="1" index="0"/>
      <attributeEditorField name="description" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid" showLabel="1" index="2"/>   
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="3"/>
      <attributeEditorField name="name" showLabel="1" index="4"/>
      <attributeEditorField name="name_codespace" showLabel="1" index="5"/>
    </attributeEditorContainer>
    <!-- database info -->
    <attributeEditorContainer name="Database Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
        <attributeEditorField name="termination_date" showLabel="1" index="7"/>
        <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
        <attributeEditorField name="updating_person" showLabel="1" index="11"/>
        <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
        <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <!-- relation to surface -->
    <attributeEditorContainer name="Relation to surface" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorField name="relative_to_terrain" showLabel="1" index="8"/>
      <attributeEditorField name="relative_to_water" showLabel="1" index="9"/>
    </attributeEditorContainer>
    <!-- external references -->
    <attributeEditorContainer name="Ext ref (Name)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_xx" label="Form Ext ref (Name)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Ext ref (Uri)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Ext ref (Uri)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <!--generic atts -->
    <attributeEditorContainer name="Gen Attrib (String)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (String)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Integer)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Integer)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Real)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Real)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Measure)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Measure)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Date)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Date)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Uri)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Uri)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="FloorArea" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form FloorArea" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="VolumeType" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form VolumeType" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <!-- other atts -->
    <attributeEditorContainer visibilityExpression="" groupBox="1" name="Feature-specific attributes" columnCount="2" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="building_thermalzone_id" showLabel="1" index="14"/>
      <attributeEditorField name="infiltrationrate" showLabel="1" index="15"/>
      <attributeEditorField name="infiltrationrate_uom" showLabel="1" index="16"/>
      <attributeEditorField name="iscooled" showLabel="1" index="17"/>
      <attributeEditorField name="isheated" showLabel="1" index="18"/>
    </attributeEditorContainer>
    
  </attributeEditorForm>
  <editable>
    <field editable="0" name="building_thermalzone_id"/>
    <field editable="0" name="creation_date"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="0" name="id"/>
    <field editable="0" name="last_modification_date"/>
    <field editable="0" name="lineage"/>
    <field editable="0" name="ng_co_id"/>
    <field editable="0" name="termination_date"/>
    <field editable="0" name="updating_person"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>2</layerGeometryType>
</qgis>
